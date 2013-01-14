class check_mk::pnp4nagios(
	$broker_lib,
	$perfdata_dir,
	$var_dir,
) { 
	package{"pnp4nagios": ensure => present }

	file{"${perfdata_dir}":
		ensure => directory,
		mode => 644, 
		owner => "${::check_mk::nagios::user}",
		group => "${::check_mk::nagios::group}"
	}
	if $::osfamily == RedHat {
		Pacakge["pnp4nagios"]{ notify => Service[apache] }
	}
	file{"${var_dir}":
		ensure => directory,
		mode => 644,
		owner => "nagios",
		group => "nagios",
	}

	service{"npcd":
		ensure => running,
		require => File["${perfdata_dir}"]
	}	
}
