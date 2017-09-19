#!/usr/bin/env bash

#export ANSIBLE_PLAYBOOK='site.yml' #this is default

export ANSIBLE_BASE_RUN_MODE='playbook'
./base_run.sh "${@}"
