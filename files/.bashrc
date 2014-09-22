alias removepe="/vagrant/puppet-enterprise/puppet-enterprise-uninstaller -dpy -l /vagrant/uninstall.log"
alias installpe="/vagrant/puppet-enterprise/puppet-enterprise-installer -D -a /vagrant/answers/$(hostname -s).answer -l /vagrant/$(hostname -s)-install.log"
alias dope="removepe && installpe"
PS1='\\[\\e[0;31m\\]\\u\\[\\e[m\\] \\[\\e[1;34m\\]\\w\\[\\e[m\\] \\[\\e[0;31m\\]\\$ \\[\\e[m\\]\\[\\e[0;32m\\]'
