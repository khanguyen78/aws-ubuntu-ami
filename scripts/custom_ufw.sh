#!/bin/bash -e

################################################################################
#   BASH SCRIPT TO APPLY PRELIMINARY ACTIONS BASED ON NOC CUSTOM REQUIREMENTS  #
#                                                                              #
#  Performs  :                                                                 #
#   -  ENABLE UFW & IPTABLES rules                                             #
#                                                                              #
################################################################################

export DEBIAN_FRONTEND="noninteractive"
INFO="[ INFO ] --"


function UFW_ENABLE () {
  IS_UFW_ENABLED=$(ufw status | awk 'NR==1{ print $2}')

  ## IF ELSE LOGIC BLOCK TO ENABLE UFW and add appropriate iptable rules ##
  if [[ "${IS_UFW_ENABLED}" = "inactive" ]];
  then
    echo -e "\n${INFO}\tUFW IS IN INACTIVE STATE.\n"
    systemctl enable ufw && systemctl restart ufw
    ufw default allow INPUT
    ufw default allow OUTPUT
    ufw default allow FORWARD
  else
    echo -e "\n${INFO}\tUFW IS IN ACTIVE STATE.\n"
    systemctl enable ufw && systemctl restart ufw
    ufw default allow INPUT
    ufw default allow OUTPUT
    ufw default allow FORWARD
  fi
  ## IF ELSE LOGIC BLOCK TO ENABLE UFW and add appropriate iptable rules ##
}



function main_caller () {
  UFW_ENABLE

}

main_caller
