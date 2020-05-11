Facter.add("admin_pass") do
  require 'YAML'

  hiera = YAML.load_file("c:\\programdata\\puppetlabs\\code\\environments\\production\\hieradata\\account\\account.yaml")

  answer = hiera['admin_password']

  setcode do
    answer
  end
end
