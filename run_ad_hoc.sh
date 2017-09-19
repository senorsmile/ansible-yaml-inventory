#!/usr/bin/env bash

#---------------------------
# EXAMPLE
#
# ./run_ad_hoc aws -m shell -a 'uptime'
#
#---------------------------

export ANSIBLE_BASE_RUN_MODE='ad-hoc'
./base_run.sh "${@}"
