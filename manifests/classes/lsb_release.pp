# common/manifests/classes/lsb_release.pp -- request the installation of
# lsb_release to get to lsbdistcodename, which is used throughout the manifests
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# This lightweight class only asserts that $lsbdistcodename is set.
# If the assertion fails, an error is printed on the server
# 
# To fail individual resources on a missing lsbdistcodename, require
# Exec[assert_lsbdistcodename] on the specific resource
class assert_lsbdistcodename {

	case $lsbdistcodename {
		'': {
			err("Please install lsb_release or set facter_lsbdistcodename in the environment of $fqdn")
			exec { "/bin/false # assert_lsbdistcodename": alias => assert_lsbdistcodename }
		}
		default: {
			exec { "/bin/true # assert_lsbdistcodename": alias => assert_lsbdistcodename }
			exec { "/bin/true # require_lsbdistcodename": alias => require_lsbdistcodename }
		}
	}

}

# To fail the complete compilation, include this class
class require_lsbdistcodename inherits assert_lsbdistcodename {
	exec { "/bin/false # require_lsbdistcodename": require => Exec[require_lsbdistcodename], }
}
