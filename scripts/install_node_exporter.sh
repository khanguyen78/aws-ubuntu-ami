#!/bin/bash -e

export DEBIAN_FRONTEND="noninteractive"
INFO="[ INFO ] --"
echo "${INFO}\tSetting up Node Exporter"

dependencies="wget tar"
package="node_exporter"
version="1.3.1"
osarch="linux-amd64"
extract_path="/usr/local/bin"
log_config_path="/etc/rsyslog.d"
log_out="/var/log/${package}.log"


check_os () {
  if [ "$(grep -Ei 'VERSION_ID="22.04"' /etc/os-release)" ];
  then
    echo -e "\n${INFO}\tSystem OS is Ubuntu. Version is 22.04.\n\n###\tProceeding with SCRIPT Execution\t###\n"
  else
    echo -e "\n${INFO}\tThis is not Ubuntu 22.04.\n\n###\tScript execution HALTING!\t###\n"
    exit 2
  fi
}

setup_dependencies () {
  for dependency in ${dependencies};
  do
    if dpkg -s "${dependency}" &> /dev/null;
      then
        echo -e "\n${INFO}\t${dependency} is already available and installed within the system."
      else
        echo -e "${INFO}\tAbout to install:\t${dependency}."
        apt-get install "${dependency}" -y
    fi
  done
}

add_node_exporter_user () {
  if id ${package} &> /dev/null;
    then
      echo -e "\n${INFO}\tThe user:\t${package}\tdoes exist. Nothing to create\n"
    else
      echo -e "\n${INFO}\tThe user:\t${package}\tdoesn't exist. Creating user:\t${package}\t"
      #We can't use --no-create-home because it conflicts with CIS benchmark
      useradd -U -m --shell /bin/false ${package}
  fi
}

remove_node_exporter_user () {
  if id ${package} &> /dev/null;
    then
      echo -e "\n${INFO}\tThe user:\t${package}\tdoes exist. Removing user:\t${package}\t\n"
      userdel -r ${package}
    else
      echo -e "\n${INFO}\tThe user:\t${package}\tdoesn't exist. Nothing to remove."
  fi
}

node_exporter_log_config_template () {
  cat <<EOF >${log_config_path}/${package}.conf
if ( \$programname startswith "${package}" ) then {
    action(type="omfile" file="${log_out}" flushOnTXEnd="off" asyncWriting="on")
    stop
}

EOF
}

create_node_exporter_log_config () {
  if [ -f "${log_config_path}/${package}.conf" ];
    then
      echo -e "\n${INFO}\tRemoving pre-existing ${package} rsyslog config file:\t${log_config_path}/${package}.conf\n"
      rm -rfv ${log_config_path}/${package}.conf
      echo -e "\n${INFO}\tCreating ${package} rsyslog config file:\t${log_config_path}/${package}.conf\n"
      node_exporter_log_config_template
    else
      echo -e "\n${INFO}\tCreating ${package} rsyslog config file:\t${log_config_path}/${package}.conf\n"
      node_exporter_log_config_template
  fi
}

remove_node_exporter_log_config () {
  if [ -f "${log_config_path}/${package}.conf" ];
    then
      echo -e "\n${INFO}\tRemoving ${package} rsyslog config file:\t${log_config_path}/${package}.conf\n"
      rm -rfv ${log_config_path}/${package}.conf
    else
      echo -e "\n${INFO}\t${package} rsyslog config file:\t${log_config_path}/${package}.conf\tdoes not exist.\n"
  fi
}

check_if_node_exporter_installed () {
  check_if_node_exporter_service_exists
  check_if_node_exporter_service_running
  if command -v ${package} &> /dev/null;
    then
      echo -e "\n${INFO}\tYES: ${package} is IN an installed state within the system and executable binary is present at:\t$(command -v ${package})\n"
      exit 0
    else
      echo -e "\n${INFO}\tNO: ${package} is NOT IN an installed state.\n"
  fi
}

node_exporter_installer () {
  echo -e "\n${INFO}\tCreating temporary directory as workspace till installation is complete."
  mkdir -pv /tmp/${package}_tempdir
  wget -v -O /tmp/${package}.tar.gz https://github.com/prometheus/${package}/releases/download/v${version}/${package}-${version}.${osarch}.tar.gz  &> /dev/null
  echo -e "\n${INFO}\tExtracting: /tmp/${package}.tar.gz \t to:\t /tmp/${package}_tempdir"
  tar -xzf /tmp/${package}.tar.gz -C /tmp/${package}_tempdir --strip-components=1
  echo -e "\n${INFO}\tRemoving:\t/tmp/${package}.tar.gz" && rm -rv /tmp/${package}.tar.gz
  echo -e "\n${INFO}\tMoving binary files to:\t${extract_path}\n"
  mv -v /tmp/${package}_tempdir/${package} ${extract_path}/
  echo -e "\n${INFO}\tAssigning ownership of:\t${extract_path}/${package}\n"
  chown -Rv ${package}:${package} ${extract_path}/${package}
  echo -e "\n${INFO}\tEnsuring appropriate permission of:\t${extract_path}/${package}\n"
  chmod -v 0755 ${extract_path}/${package}
  echo -e "\n${INFO}\tRemoving temporary directory."
  rm -rfv /tmp/${package}_tempdir
}

node_exporter_uninstaller () {
  if command -v ${package} &> /dev/null;
    then
      package_loc=$(command -v ${package})
      rm -v ${package_loc}
    else
      echo -e "\n${INFO}\tNO: ${package} is NOT IN an installed state.\n"
      exit 2
  fi
}

check_if_node_exporter_service_exists () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "\n${INFO}\tNO: ${package} service does not exist on the system.\n"
  else
    echo -e "\n${INFO}\tYES: ${package} service exists on the system. It exists at:\t${fragment_path}"
  fi
}

check_if_node_exporter_service_running () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  service_state=$(systemctl is-active ${package} || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "\n${INFO}\tNO: ${package} service is not available.\n"
  elif [[ "${service_state}" = "active" ]];
  then
    echo -e "\n${INFO}\tYES: ${package} service is in active running state."
  else
    echo -e "\n${INFO}\tYES: ${package} service is not in active running state."
  fi
}

add_node_exporter_service () {
  echo -e "\n${INFO}\tCreating service for:\t${package}"
  cat <<EOF >/etc/systemd/system/${package}.service
[Unit]
Description=node_exporter - exporter for machine metrics.
Wants=network-online.target
After=network-online.target

[Service]
User=${package}
Group=${package}
Type=simple
ExecStart=${extract_path}/${package} --collector.systemd --collector.processes --collector.mountstats
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=${package}

[Install]
WantedBy=multi-user.target
EOF
}

remove_node_exporter_service () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService file for:\t${package} does not exist."
  else
    package_service_loc=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g')
    rm -v ${package_service_loc}
  fi
}

systemctl_daemon_reload () {
  echo -e "\nPerforming systemctl daemon reload."
  systemctl daemon-reload
}

node_exporter_service_status () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService:\t${package} does not exist."
  else
    systemctl status --no-pager -l ${package}
  fi
}

node_exporter_service_enable () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService:\t${package} does not exist."
  else
    systemctl enable ${package}
  fi
}

node_exporter_service_disable () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService:\t${package} does not exist."
  else
    systemctl disable ${package}
  fi
}

node_exporter_service_start () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService:\t${package} does not exist."
  else
    systemctl start ${package}
  fi
}

node_exporter_service_restart () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService:\t${package} does not exist."
  else
    systemctl restart ${package}
  fi
}

node_exporter_service_stop () {
  fragment_path=$(systemctl show -p FragmentPath ${package} | sed 's/^[^=]*=//g' || true)
  if [[ -z "${fragment_path}" ]];
  then
    echo -e "${INFO}\tService:\t${package} does not exist."
  else
    systemctl stop ${package}
  fi
}

case "$1" in
  check)
    check_os
    check_if_node_exporter_installed
    ;;
  install)
    check_os
    setup_dependencies
    check_if_node_exporter_installed
    echo -e "\n${INFO}\tInstallation beginning for:\t${package}\n"
    add_node_exporter_user
    create_node_exporter_log_config && systemctl restart rsyslog.service
    node_exporter_installer
    add_node_exporter_service
    systemctl_daemon_reload
    node_exporter_service_enable
    ;;
  status)
    check_os
    node_exporter_service_status
    ;;
  enable)
    check_os
    node_exporter_service_enable
    ;;
  disable)
    check_os
    node_exporter_service_disable
    ;;
  start)
    check_os
    node_exporter_service_start
    ;;
  restart)
    check_os
    node_exporter_service_restart
    ;;
  stop)
    check_os
    node_exporter_service_stop
    ;;
  uninstall)
    check_os
    node_exporter_service_stop
    remove_node_exporter_log_config && systemctl restart rsyslog.service
    echo -e "\n${INFO}\tPurging beginning for:\t${package}\n"
    remove_node_exporter_user
    node_exporter_uninstaller
    remove_node_exporter_service
    systemctl_daemon_reload
    ;;
  *)
    echo -e $"\nUsage:\t $0 check\nChecks if ${package} is installed on the system and operational.\n\n"
    echo -e $"Usage:\t $0 install\nFor installing ${package} on the system and setting up it's service.\n\n"
    echo -e $"Usage:\t $0 status\nFor checking ${package} service status on the system.\n\n"
    echo -e $"Usage:\t $0 enable\nFor enabling ${package} service on boot time of the system.\n\n"
    echo -e $"Usage:\t $0 disable\nFor disabling ${package} service on boot time of the system.\n\n"
    echo -e $"Usage:\t $0 start\nFor starting ${package} service on the system.\n\n"
    echo -e $"Usage:\t $0 restart\nFor restarting ${package} service on the system.\n\n"
    echo -e $"Usage:\t $0 stop\nFor stopping ${package} service on the system.\n\n"
    echo -e $"Usage:\t $0 uninstall\nFor uninstalling/purging ${package} and it's from the system.\n"
    exit 1
esac
