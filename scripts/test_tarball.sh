#!/bin/bash -

set -o nounset                              # Treat unset variables as an error
set -e

while getopts c name; do
    case "$name" in
        s)
            LAYOUT='split'
            ;;
        ?)
            ;;
    esac
done

PE_VER="${PE_VER:=3.4}"
target_platform=${PE_PLATFORM:-'debian-7-amd64'}
layout=${LAYOUT:-'mono'}

basename="puppet-enterprise-${PE_VER?}-test-${target_platform?}"

echo "Building ${basename?}.tar"

pushd puppet-enterprise > /dev/null
gtar cf ../../"${basename?}.tar" . --transform "s,^\\.,${basename?}," 
popd > /dev/null

echo "Generating beaker.cfg"

if [ "split" != "${layout?}" ]; then
  cat > beaker.cfg <<CFG
HOSTS:
  pe-monolithic:
    roles:
      - master
      - dashboard
      - database
      - agent
    platform: ${target_platform?}
    pe_ver: ${PE_VER?}-test
    pe_dir: $(pwd)
CONFIG:
  nfs_server: none
  consoleport: 443
CFG
else
  cat > beaker.cfg <<CFG
HOSTS:
  pe-master:
    roles:
      - master
      - agent
    platform: ${target_platform?}
    pe_ver: ${PE_VER?}-test
    pe_dir: $(pwd)
  pe-puppetdb:
    roles:
      - database
      - agent
    platform: ${target_platform?}
    pe_ver: ${PE_VER?}-test
    pe_dir: $(pwd)
  pe-console:
    roles:
      - dashboard
      - agent
    platform: ${target_platform?}
    pe_ver: ${PE_VER?}-test
    pe_dir: $(pwd)
CONFIG:
  nfs_server: none
  consoleport: 443
CFG
fi

echo "Running tests"

export BUNDLE_GEMFILE=../pe_acceptance_tests/Gemfile
bundle exec beaker -c beaker.cfg -t ../pe_acceptance_tests/acceptance/tests --pre-suite ../pe_acceptance_tests/setup/install.rb

echo "Cleaning up"

rm "${basename?}.tar"
rm beaker.cfg
