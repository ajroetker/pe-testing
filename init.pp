$pe_testing = "/Users/aroetker/Projects/pe-testing"
$scripts = "/Users/aroetker/Projects/pe-testing/scripts"
$files = "/Users/aroetker/Projects/pe-testing/files"
$tarballs = "/Users/aroetker/Projects/pe-testing/tarballs"
$versions = "/Users/aroetker/Projects/pe-testing/versions"
$packages = "/Users/aroetker/Projects/pe-testing/packages"
$answers = "/Users/aroetker/Projects/pe-testing/answers"
file { [ $pe_testing,
         $scripts,
         $files,
         $tarballs,
         $versions,
         $answers, ] :
           ensure => directory,
}

$gemfile_content = "source 'https://rubygems.org'
gem 'puppet', '~> 3.7.1'"
$bashrc_conent = "alias installpe='/vagrant/puppet-enterprise/puppet-enterprise-uninstaller -dpy -l /vagrant/uninstall.log && /vagrant/puppet-enterprise/puppet-enterprise-installer -D -a /vagrant/answers/#{name}.answer -l /vagrant/#{name}-install.log'
PS1='\\[\\e[0;31m\\]\\u\\[\\e[m\\] \\[\\e[1;34m\\]\\w\\[\\e[m\\] \\[\\e[0;31m\\]\\$ \\[\\e[m\\]\\[\\e[0;32m\\]'"
