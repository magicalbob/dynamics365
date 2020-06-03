#!/usr/bin/env bash

# check that BRANCH_NAME exists, otherwise set it to "master"
if [[ -z "$BRANCH_NAME" ]]
then
  export BRANCH_NAME=master
fi

vagrant destroy -f

VBoxManage list vms |grep dynamics_vbox_${BRANCH_NAME}| grep -o "{[0-9a-f\\-]*}"|cut -d{ -f2|cut -d} -f1|sed 's/^/VBoxManage controlvm /'|sed 's/\$/ poweroff/'|sh -||echo "Already powered off"

VBoxManage list vms |grep dynamics_vbox_${BRANCH_NAME}| grep -o "{[0-9a-f\\-]*}"|cut -d{ -f2|cut -d} -f1|sed 's/^/VBoxManage unregistervm /'|sed 's/\$/ --delete/'|sh -
