echo "Power Off Machines"
echo "=================="
VBoxManage list runningvms|grep .$1|cut -d{ -f2|cut -d} -f1|sed 's/^/VBoxManage controlvm /'|sed 's/$/ poweroff/'|sh -
echo "==============="
echo "Remove Machines"
echo "==============="
VBoxManage list vms|grep .$1|cut -d{ -f2|cut -d} -f1|sed 's/^/VBoxManage unregistervm --delete  /'|sh -
