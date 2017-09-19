#!/usr/bin/env bash
export ANSIBLE_FORCE_COLOR="${ANSIBLE_FORCE_COLOR:-true}"
#export ANSIBLE_NOCOLOR="${ANSIBLE_NOCOLOR:-false}"
export VAGRANT_MODE="${VAGRANT_MODE:-0}" #1=enabled, disabled by default
#set -x

INOPTS=("$@")

if [ $# -eq 0 ]; then
    echo "No arguments provided, please provide at least one argument"
    echo "Example: ./run_this.sh -v"
    exit 1
fi

mode="${ANSIBLE_BASE_RUN_MODE:-playbook}"
echo "****** RUN MODE= ${ANSIBLE_BASE_RUN_MODE}"

if [[ ${ANSIBLE_BASE_RUN_MODE} == 'playbook' ]]; then
  playbook="${ANSIBLE_PLAYBOOK:-site.yml}"
  echo "****** PLAYBOOK= ${playbook}"
fi

echo "****** VAGRANT_MODE= ${VAGRANT_MODE}"


source use_ansible_20.sh

#starttime=$(date)

# Plaintext vault decryption key, not checked into SCM
VAULT_PASSWORD_FILE=$HOME/.ssh/creds/ansible_vault.txt
[ -f $VAULT_PASSWORD_FILE ] && {
  VAULTOPTS="--vault-password-file=$VAULT_PASSWORD_FILE"
} ||  {
  VAULTOPTS="--skip-tags requires_vault"
}

run_ansible() {
  [[ $(hostname) == 'jenkins-prime.mtnsat.io' ]] && {
    setup_ara
  }

  if [[ ${ANSIBLE_BASE_RUN_MODE} == 'playbook' ]]; then
    #ansible-playbook --diff "${playbook}" $VAULTOPTS $INOPTS
    ansible-playbook --diff "${playbook}" $VAULTOPTS "${INOPTS[@]}"
  elif [[ ${ANSIBLE_BASE_RUN_MODE} == 'ad-hoc' ]]; then
    ansible "${INOPTS[@]}" $VAULTOPTS
    #ansible $INOPTS $VAULTOPTS
  else
    echo "Invalid run mode: ${ANSIBLE_BASE_RUN_MODE}"
    exit 15
  fi
}

time run_ansible
retcode=$?

exit $retcode
