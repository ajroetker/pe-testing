#!/bin/bash -

set -o nounset                              # Treat unset variables as an error
set -e

while getopts s name; do
    case "$name" in
        s)
            LAYOUT='split'
            ;;
        ?)
            ;;
    esac
done

pe_testing="$( dirname "${BASH_SOURCE[0]}" )/.."
PE_VER="${PE_VER:=3.4}"
target_platform=${PE_PLATFORM:-'debian-7-amd64'}
layout=${LAYOUT:-'mono'}

basename="puppet-enterprise-${PE_VER?}-test-${target_platform?}"

echo "Building ${basename?}.tar"

pushd "${pe_testing}/puppet-enterprise" > /dev/null
gtar cf "${pe_testing}/tarballs/${basename?}.tar" . --transform "s,^\\.,${basename?}," 
popd > /dev/null

echo "Generating beaker.cfg"

if [ "split" != "${layout?}" ]; then
  cat > "${pe_testing}/beaker.cfg" <<CFG
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
    pe_dir: ${pe_testing}
CONFIG:
  nfs_server: none
  consoleport: 443
CFG
fi

echo "Running tests"

pe_acceptance_tests="${pe_testing}/../pe_acceptance_tests"
export BUNDLE_GEMFILE="${pe_acceptance_tests}/Gemfile"
bundle exec beaker -c "${pe_testing}/beaker.cfg" -t "${pe_acceptance_tests}/acceptance/tests" --pre-suite "${pe_acceptance_tests}/setup/install.rb"

echo "Cleaning up"

rm "${pe_testing}/tarballs/${basename?}.tar"
rm "${pe_testing}/beaker.cfg"
