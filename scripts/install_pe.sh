#!/usr/bin/env bash

# Copy puppet modules to /opt/puppet/share/installer/modules so that they can
# be served by a puppet fileserver mount to compile masters. This will remove
# any existing modules in the directory on upgrades.
create_module_mount() {
    rm -rf /opt/puppet/share/installer/modules

    mkdir -p /opt/puppet/share/installer/modules
    cp -R /vagrant/puppet-enterprise/modules /opt/puppet/share/installer/modules
d
}

apt-get install pe-agent -y
for module in /vagrant/puppet-enterprise/modules/*.tar.gz; do
    /opt/puppet/bin/puppet module install $module --force --modulepath /opt/puppet/share/puppet/modules
done

/opt/puppet/bin/puppet config set certname $(hostname -f) --section main
/opt/puppet/bin/puppet config set server $(hostname -f) --section main
if [ ! -e "$(/opt/puppet/bin/puppet master --configprint hostcert)" ]; then
    /opt/puppet/bin/puppet cert generate $(hostname -f) --dns_alt_names $(hostname -s),$(hostname -f) --ca_name "Puppet CA generated on $(hostname -f) at $(date '+%Y-%m-%d %H:%M:%S %z')"
fi

for certname in classifier dashboard mcollective-servers peadmin-mcollective-client puppet-console-mcollective-client; do
    if [ ! -s "/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-${certname}.pem" ]; then
        /opt/puppet/bin/puppet cert generate pe-internal-$certname;
    fi
done

create_module_mount

/opt/puppet/bin/puppet apply /vagrant/manifests/install_pe.pp --node_name_value pe-monolithic
