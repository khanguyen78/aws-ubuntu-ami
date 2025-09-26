# Import the libraries
import boto3, jinja2, os

# Import our defaults,paths, template config
from config import *

# Import subprocess so we can run commands
from subprocess import call


# Allows us to merge paramstore values into one list
def merge_lists(l1, l2, key):
  merged = {}
  for item in l1+l2:
    if item[key] in merged:
      merged[item[key]].update(item)
    else:
      merged[item[key]] = item
  return [val for (_, val) in merged.items()]

# filter for jinja2.  Use this to allow overriding by env variable.  useful for docker.
def env_override(value, key):
  return os.getenv(key, value)

def get_parameters(p):
  response = client.get_parameters_by_path(
      Path=p,
      Recursive=True,
      WithDecryption=True,
      MaxResults=10,
  )
  parameters = response['Parameters']
  outparams = merge_lists(outparams, parameters, 'Name')

# Allows us to override the region by environment variable.
region = env_override('us-east-1', 'AWS_DEFAULT_REGION')

# Set up the AWS SDK client.
client = boto3.client('ssm', region_name=region)

# prepare the merged list by setting it to our defaults
outparams = defaults

# Loop through the required paths (ssm_paths) from config.
# We will assume encryption and recursive

for ssm_path in ssm_paths:
  paginator = client.get_paginator('get_parameters_by_path')

  response = paginator.paginate(
    Path=ssm_path,
    Recursive=True,
    WithDecryption=True,
    PaginationConfig={
     'MaxItems': 1000,
    }
  )

  for page in response:
    parameters = page['Parameters']
    outparams = merge_lists(outparams, parameters, 'Name')

# end for ssm_path

# Let's normalize all the names to nested dictionary, split by /
# We will pass template_input to the template(s)
template_input  = {}
tree = {}
for parameter in outparams:
  tvar_name = parameter['Name'].strip('/')
  tvar_value = parameter['Value']
  t = tree
  for part in tvar_name.split('/')[:-1]:
    t = t.setdefault(part, {})
  t.setdefault(tvar_name.split('/')[-1], tvar_value)

  #print(tree)
  template_input.update(tree)



# example of reading a var in a template.
# template_out = template.render(vardict = template_input)
# vardict[APP_ENVIRONMENT]['cert']['gsactacdev']['key']['pem'] }}

# Let's initialize our Jinja2 environment.
tplLoader = jinja2.FileSystemLoader(searchpath="./")
tplEnv = jinja2.Environment(loader=tplLoader)
# Let's create a custom filter to allow for environment variable to override values
tplEnv.filters['env_override'] = env_override

tplCommands = []

for template in templates:
  # read the template
  tpl = tplEnv.get_template(template['Path'])
  # stream directly to the destination.
  tpl.stream(tplvars = template_input).dump(template['Dest'])
  # Add the command to the list to execute after all templates are rendered.
  if template['Command']:
    tplCommands.append(template['Command'])

# Make sure we have unique commands.
tplCommands = list(set(tplCommands))

# Execute the commands
for tplCommand in tplCommands:
  call(tplCommand, shell=True)

# We are all done.




