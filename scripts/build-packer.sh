if [ "${OS}" == "Windows_NT" ]
then
  PATH=$PATH:/c/tools/ruby27/bin:"/c/Program Files/Oracle/VirtualBox"
  export JENKINS_NODE_COOKIE=dontKillMe 
  export BUILD_ID=dontKillMe
fi

export OS_TYPE=windows
#export ISO_URL=https://dev.ellisbs.co.uk/files/software/WinServer2016.iso
#export ISO_MD5=0b171c917909e824967ca7108ff9404f
# use the below values for windows server 2019
export ISO_URL=https://dev.ellisbs.co.uk/files/software/WinServer2019.iso
export ISO_MD5=70fec2cb1d6759108820130c2b5496da
export WINRM_USERNAME=$(grep admin_username ./puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')
export WINRM_PASSWORD=$(grep admin_password ./puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')
export DISK_SIZE=51200
export VBOX_VER=$(VBoxManage --version | cut -dr -f1)

echo "{" > answer_files/AutoUnattend.data.yml
echo "admin_password: ${WINRM_PASSWORD}," >> answer_files/AutoUnattend.data.yml
echo "admin_username: ${WINRM_USERNAME}" >> answer_files/AutoUnattend.data.yml
echo "}" >> answer_files/AutoUnattend.data.yml

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

# Check box was produced
if [ -f dynamics-windows-virtualbox.box ]
then
  mv dynamics-windows-virtualbox.box /tmp
  echo "dynamics-windows-virtualbox.box was produced."
else
  echo "dynamics-windows-virtualbox.box was not produced. Fail!"
  exit -1
fi
