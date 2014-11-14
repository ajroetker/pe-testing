#!/bin/bash -

set -o nounset                              # Treat unset variables as an error
set -e

pe_testing="$( dirname "${BASH_SOURCE[0]}" )/.."
pe_acceptance_tests="${pe_testing}/../pe_acceptance_tests"
q_puppet_enterpriseconsole_auth_password=password ${pe_acceptance_tests}/bin/beaker --color --debug --type pe --config "${pe_testing}/beaker_nopresuite.cfg" --tests "${pe_acceptance_tests}/acceptance/tests"
