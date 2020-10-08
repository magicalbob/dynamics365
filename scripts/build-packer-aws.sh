if [ "${OS}" == "Windows_NT" ]
then
  PATH=$PATH:/c/tools/ruby27/bin:"/c/Program Files/Oracle/VirtualBox"
fi

export WINRM_USERNAME=administrator
export WINRM_PASSWORD=$(grep admin_password ./puppet/hieradata/account/account.yaml |cut -d: -f2|sed 's/ //g')

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
packer build -force packer-aws.json

