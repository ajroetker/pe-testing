#!/bin/bash -

set -o nounset                              # Treat unset variables as an error
set -e

pe_testing="$( dirname "${BASH_SOURCE[0]}" )/.."
pe_acceptance_tests="${pe_testing}/../pe_acceptance_tests"
export BUNDLE_GEMFILE="${pe_acceptance_tests}/Gemfile"
q_puppet_enterpriseconsole_auth_password=password bundle exec beaker --color --debug --type pe --config "${pe_testing}/beaker_nopresuite.cfg" --tests "${pe_acceptance_tests}/acceptance/tests"
