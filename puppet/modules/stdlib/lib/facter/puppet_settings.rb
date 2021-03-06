# frozen_string_literal: true

# These facter facts return the value of the Puppet vardir and environment path
# settings for the node running puppet or puppet agent.  The intent is to
# enable Puppet modules to automatically have insight into a place where they
# can place variable data, or for modules running on the puppet server to know
# where environments are stored.
#
# The values should be directly usable in a File resource path attribute.
#
begin
  require 'facter/util/puppet_settings'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__), 'util', 'puppet_settings.rb')
  load rb_file if File.exist?(rb_file) || raise(e)
end

# Facter fact returns the value of the Puppet vardir
Facter.add(:puppet_vardir) do
  setcode do
    Facter::Util::PuppetSettings.with_puppet do
      Puppet[:vardir]
    end
  end
end

# Facter fact returns the value of the Puppet environment path
Facter.add(:puppet_environmentpath) do
  setcode do
    Facter::Util::PuppetSettings.with_puppet do
      Puppet[:environmentpath]
    end
  end
end

# Facter fact returns the value of the Puppet server
Facter.add(:puppet_server) do
  setcode do
    Facter::Util::PuppetSettings.with_puppet do
      Puppet[:server]
    end
  end
end
