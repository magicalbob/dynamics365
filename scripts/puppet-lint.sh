#!/usr/bin/env bash
PUPPET_DIR=`dirname $0`/../puppet
puppet-lint --no-80chars-check --no-variable_scope-check  $PUPPET_DIR| egrep -v '(stdlib|chocolatey|archive|registry|windows_env)'
