#!/usr/bin/env bash

#-------------------------------------
# install and run ansible 2.x from virtualenv
# or from github source checked out in /tmp
#
# Authors: Shaun Smiley
#           Rowin Andruscavage
#-------------------------------------

#-------------------------------------
##- vars
#-------------------------------------
## virtualenv or git
run_mode="${USE_ANSIBLE_MODE:-virtualenv}"

## virtualenv configuration
[[ -n $USE_ANSIBLE_VENV_DIR && -n $USE_ANSIBLE_VENV_REQ ]] && {
  VENV="${USE_ANSIBLE_VENV_DIR:-venv-ansible2.0}"
  REQUIREMENTS="${USE_ANSIBLE_VENV_REQ:-requirements-ansible2.0.txt}"
} || {
  [[ -n $USE_ANSIBLE_VENV_VER ]] || {
    USE_ANSIBLE_VENV_VER='2.4' #default
  }

  case $USE_ANSIBLE_VENV_VER in
    2.4)
      VENV='venv-ansible2.4'
      REQUIREMENTS='requirements-ansible2.4.txt'
      ;;
    *)
      echo 'unrecognized USE_ANSIBLE_VENV_VER'
      exit 1
      ;;
  esac
}

## git checkout dir
co='/usr/local/bin/ansible-git'
co_run="${co}/hacking/env-setup"

## debug mode
debug_mode="${USE_ANSIBLE_DEBUG:-false}"
[[ $debug_mode == 'true' ]] && { echo "run_mode: ${run_mode}"; echo; }

## git checkout tag
# ansible_ver="${USE_ANSIBLE_VER:-v2.0.2.0-1}"
# ansible_ver="${USE_ANSIBLE_VER:-v2.1.3.0-1}"
# ansible_ver="${USE_ANSIBLE_VER:-v2.2.1.0-1}"
ansible_ver="${USE_ANSIBLE_VER:-v2.3.1.0-1}" # default for git method

#-------------------------------------
##- functions
#-------------------------------------

virtualenv_setup() {
  ## One-time OS setup for virtualenv

  ## Ubuntu virtualenv install
  [[ $(which apt-get) ]] && {
    [[ $(which virtualenv) ]] || {
      sudo apt-get install -y python-virtualenv
    }
    for PKG in python-dev libffi-dev libssl-dev build-essential ; do
      [[ $(dpkg -s $PKG) ]] || {
        sudo apt-get install -y -f $PKG
      }
    done
  }

  ## Mac OS X virtualenv install
  [[ $(uname) == 'Darwin' ]] && {
    [[ $(which virtualenv) ]] || {
      brew install pyenv-virtualenv
    }
  }
}

run_from_virtualenv() {
  [ -d $VENV ] || {
    virtualenv $VENV
    source ./$VENV/bin/activate
    pip install -U setuptools
    pip install -U pip
    pip install -r $REQUIREMENTS
    deactivate
  }

  echo "Sourcing ansible venv."
  source ./$VENV/bin/activate
  echo "Ensuring python requirements."
  [[ $debug_mode == 'true' ]] && {
    pip install -r $REQUIREMENTS
  } || {
    pip install -r $REQUIREMENTS >/dev/null
  }

  echo; ansible --version; echo
}

co_version() {
  ## checkout desired version of ansible from git
  cd "${co}" >/dev/null 2>&1

  local current_version=$(git describe --tags)
  [[ "$current_version" == "$ansible_ver" ]] && {
    echo "Already on ansible $ansible_ver."
  } || {
    echo "Updating ansible git..."
    git checkout devel >/dev/null 2>&1
    git pull --rebase >/dev/null 2>&1
    git checkout "${ansible_ver}" >/dev/null 2>&1
    git submodule update --init --recursive >/dev/null 2>&1
    #verify what tag we're on now
    echo "Now on Ansible $(git describe --tags)"
  }

}

source_ansible() {
  ## source ansible 2.0 into current shell
  # echo "Sourcing ansible 2.0 from ${co}"
  source "${co_run}" >/dev/null 2>&1
}

run_from_git() {
  [[ $(which git) ]] || {
      echo "Git not installed.  Aborting..."
      exit 1
  }

  [[ -f "${co_run}" ]] || {
      echo "Ansible git repo not yet checked out at ${co}."
      sudo mkdir "${co}"
      sudo chown $(whoami) "${co}"
      git clone https://github.com/ansible/ansible.git "${co}"
  }

  ## save current directory
  pushd .  >/dev/null 2>&1

  co_version
  source_ansible

  ## return to original directory
  popd  >/dev/null 2>&1

  echo; ansible --version; echo
}

#-------------------------------------
##- main
#-------------------------------------
[[ $run_mode == 'virtualenv' ]] && run_from_virtualenv
[[ $run_mode == 'git' ]] && run_from_git

#-------------------------------------
