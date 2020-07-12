#!/bin/bash -x

main() {
  # random wait for the system services to start
  sleep 300
  # disabling auto update of package cache
  function wait_for_apt_lock() {
      while [ "" = "" ]; do
          eval "$1" 2>/dev/null
          if [ $? -eq 0 ]; then
              break
          fi
          sleep 10
          echo "Waiting for apt lock to be released..."
      done
  }
  wait_for_apt_lock "sudo apt update"
  sudo apt upgrade

  # adding ansible repo
  sudo apt-add-repository --yes --update ppa:ansible/ansible

  # list of system packages to be installed. please add any new packages that need to be installed to the variable "packages_to_install"
  packages_to_install=( vim htop sysstat atop software-properties-common ansible python-apt locales locales-all )
  locale-gen "en_US.UTF-8"

  for package in "${packages_to_install[@]}"
  do
    sudo apt install -y $package
  done 

  # locale-gen --purge en_US.UTF-8
  # echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
  update-locale LC_ALL=en_US.UTF-8
  update-locale LC_CTYPE=en_US.UTF-8
  
 
  ansible-galaxy install -r /tmp/cis_hardening/roles/requirements.yml
  ansible-playbook -l localhost /tmp/cis_hardening/tasks/main.yml
  ## DO NOT MAKE ANY CHANGES BEYOND THIS 
  # random wait for the system services to start
  sudo apt remove ansible -y && sudo apt autoremove -y
}

main
