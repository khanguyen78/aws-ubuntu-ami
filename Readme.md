Folder Structure

```
.
├── .github/workflows/ami-pipeline.yml
├── packer/
│   └── ubuntu-ami.pkr.hcl
├── ansible/
│   └── playbook.yml
└── infra/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── harden.yml

```

Github Secrets Required
| Secret Name             | Description                              |
| ----------------------- | ---------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your AWS access key                      |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key                      |
| `SUBNET_ID`             | Subnet ID for EC2 infrastructure         |
| `SECURITY_GROUP_ID`     | Security group ID                        |
| `INSTANCE_PROFILE`      | EC2 instance profile with required roles |

