$projects = '/Users/aroetker/Projects'
$pe_testing = "${projects}/pe-testing"
$scripts    = "${projects}/pe-testing/scripts"
$files      = "${projects}/pe-testing/files"
$tarballs   = "${projects}/pe-testing/tarballs"
$versions   = "${projects}/pe-testing/versions"
$packages   = "${projects}/pe-testing/packages"
$answers    = "${projects}/pe-testing/answers"
$boxes      = "${projects}/pe-testing/boxes"
file { [ $pe_testing,
         $scripts,
         $files,
         $tarballs,
         $versions,
         $boxes,
         $answers, ] :
           ensure => directory,
}
