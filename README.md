#Setup
------
```
bundle exec puppet apply init.pp
```
You'll also want to put your public key in your `~/.ssh/authorized_keys` as well as adding the info in `pe-testing/files/hosts.example` to your `/etc/hosts`.

#Test PE
--------
##Monolithic
```
./scripts/build_latest.sh
vagrant up pe-monolithic
./scripts/test_tarball.sh
```
##Split
```
./scripts/build_latest.sh
vagrant up pe-master pe-puppetdb pe-console
./scripts/test_tarball.sh -s
```

#Caveats
--------
Module assumes the following directory tree
```
<projects>
+-- puppetlabs-puppet_enterprise
+-- enterprise-dist
+-- pe_acceptance_tests
+-- pe-testing
```
`./scripts/build_latest.sh` will fetch and build the latest PE with your `enterprise-dist` and `puppetlabs-puppet_enterprsie` changes. Fetches a build for `debian-7-amd64` by default, to download a `el-6-x86_64` build pass `-c`. The flag `-n` will prevent the downloading of a new build and just use the latest one in your `pe-testing/versions` directory. The flag `-f` will force download the latest build. 
`./scripts/test_tarballs.sh` will use `pe_acceptance_tests` to install and run `beaker` suite on either a monolithic or split PE install. This assumes that the vagrant boxes in the `VagrantFile` have been brought up, the proper `/etc/hosts` entries exist for those boxes, and that you have ssh access to them (this will be so if you have you're public key in your `~/.ssh/authorized_keys` before you `vagrant up`). The flag `-s` will do a split install and test. 

#VagrantFile
------------
The VagrantFile will prepare the main services nodes (master, puppetdb, and console) with nice terminal prompts, proper `/etc/hosts` and `authorized_keys`, as well as preparing machine with some useful packages. Also we prepare the machines for testing customs packages in the PE builds by installing `dpkg-dev` and allowing unsigned packages. The VagrantFile assumes testing on `debian-7-amd64`.

#Manual Stuff
-------------
If you don't with to use beaker to install PE, the vagrant boxes will come with the alias `installpe` to unistall and install PE appropriate for that node (monolithic, master, console, or puppetdb) via the files in `pe-testing/answers/`. Then `./scripts/beaker.sh` will run the acceptance tests using the config in `beaker_mono.cfg`.

#Workflow
---------
I recommend adding `pe-testing/scripts` to your `$PATH` to make things easier.  
My usual workflow:
- Pull down changes to `puppetlabs-puppet_enterprise` and `enterprise-dist`
- Check for updates to `pe_acceptance_tests`
- Run `build_latest.sh`
- `ssh root@pe-monolithic`
- `installpe`, ending the install early if you realize an issue
- `exit` the machine
- Run `beaker.sh` for acceptance tests
- Repeat until things aren't broken
