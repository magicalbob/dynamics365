if [ "${OS}" == "Windows_NT" ]
then
  PATH=$PATH:/c/tools/ruby27/bin:"/c/Program Files/Oracle/VirtualBox"
fi

export OS_TYPE=windows
#export ISO_URL=https://dev.ellisbs.co.uk/files/software/WinServer2016.iso
#export ISO_MD5=0b171c917909e824967ca7108ff9404f
# use the below values for windows server 2019
export ISO_URL=https://dev.ellisbs.co.uk/files/software/WinServer2019.iso
export ISO_MD5=70fec2cb1d6759108820130c2b5496da
export WINRM_USERNAME=administrator
export WINRM_PASSWORD=$(grep admin_password ./puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')
export DISK_SIZE=51200
export VBOX_VER=$(VBoxManage --version | cut -dr -f1)

echo "admin_password: ${WINRM_PASSWORD}" > answer_files/AutoUnattend.data.yml

source scripts/boxname.sh

# Populate AutoUnattend.xml answer file with correct details for build
mustache answer_files/AutoUnattend.data.yml answer_files/AutoUnattend.xml.template > answer_files/AutoUnattend.xml

if [[ -z "$BRANCH_NAME" ]]
then
  BRANCH_NAME=local
fi

echo "Removing puppet.zip and dynamics-windows-virtualbox.box"
rm -vf puppet.zip dynamics-windows-virtualbox.box
cd puppet
zip -qr ../puppet.zip hieradata manifests modules facter
cd ..
packer build -force packer-vbox.json

# Forcibly add the base box
vagrant box add -f dynamics-windows-virtualbox.box dynamics-windows-virtualbox.box

# Publish box to jenkins files
if [ -f dynamics-windows-virtualbox.box ]
then
  scp dynamics-windows-virtualbox.box xeon:/opt/ellisbs/files/boxes/${box_name}-windows-virtualbox-${BRANCH_NAME}.box
  echo "sudo chmod a+rwx /opt/ellisbs/files/boxes/${box_name}-windows-virtualbox-${BRANCH_NAME}.box" | ssh xeon
  echo "sudo chown nginx:nginx /opt/ellisbs/files/boxes/${box_name}-windows-virtualbox-${BRANCH_NAME}.box" | ssh xeon
else
  echo "dynamics-windows-virtualbox.box was not produced. Fail!"
  exit -1
fi
