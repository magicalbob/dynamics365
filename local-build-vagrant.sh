export OS_TYPE=windows
export ISO_URL=~/PIPAT/gitlab/pipat-packer/iso_installation/WinServer2016.iso
#export ISO_MD5=c7be22a21d688d68b54f8ad16af1e124
export ISO_MD5=0b171c917909e824967ca7108ff9404f
export WINRM_USERNAME=administrator
export WINRM_PASSWORD=vagrant
export DISK_SIZE="51200"

set -e

export LOG_FILE=build.vagrant.log
if [ -f ${LOG_FILE} ]
then
  mv -f ${LOG_FILE} ${LOG_FILE}.last
fi

rm -f puppet.zip
cd puppet
zip -qr ../puppet.zip hieradata manifests modules facter ruby
cd ..

packer build -force packer-vbox.json | tee ${LOG_FILE} 
