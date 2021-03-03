require 'json'

file = open("#{__dir__}/metadata.json")
json = file.read
output = JSON.parse(json)
metadata_string = output['operatingsystem_support']
unsupported = ['Amazon', 'Archlinux', 'AIX', 'OSX']
operating_system_list = []

for os_info in metadata_string
  os_name = os_info['operatingsystem']
  next if unsupported.include? os_name
     for os_version in os_info['operatingsystemrelease']
    os_and_version = os_name.downcase + os_version
    case os_name
    when "OracleLinux"
      os_and_version = os_and_version.sub!("linux", "")
    when "Ubuntu"
      os_and_version = os_and_version.sub!(".", "")
    when "SLES"
      os_and_version = os_and_version.sub!(" SP1", "") if os_and_version.include? ' SP1'
      os_and_version = os_and_version.sub!(" SP4", "") if os_and_version.include? ' SP4'
    when "OSX"
      os_and_version = os_and_version.sub!(".", "")
    when "Windows"
      if os_and_version.include? "Server"
        os_and_version = os_and_version.sub!("Server", "").delete(" ").downcase
      end
    end
    if os_name == "SLES" || os_name == "Solaris" || os_name == "Windows"
      os_and_version = "- '" + os_and_version + "-64default.a-redhat7-64mdca'"
    else
      os_and_version = "- '" + os_and_version + "-64default.a'"
    end
    operating_system_list << os_and_version
  end
end

puts operating_system_list
