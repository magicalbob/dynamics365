Facter.add("safemodeadminpass") do
  require 'YAML'

  hiera = YAML.load_file("c:\\programdata\\puppetlabs\\code\\environments\\production\\hieradata\\account\\account.yaml")

  answer = hiera['safemodeadminpass']

  setcode do
    answer
  end
end
