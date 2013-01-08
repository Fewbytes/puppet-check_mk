# Minimal nagios installation

class check-mk::nagios ( 
	$version,
	$user,
	$group
) inherits check-mk::nagios::config { 
	include check-mk::pnp4nagios

	package{"${check-mk::nagios::package}": }
	package{"${check-mk::nagios::plugins_package}": }
	file{"${config_dir}": mode => 644, ensure => directory }
	file{"${config_dir}/nagios.cfg": mode => 644, content => template("check-mk/nagios.cfg.erb")}

	if defined(User["${::apache::params::user}"]) {
		User["${::apache::params::user}"] { groups +> $group }
	} else { 
		user{"${::apache::params::user}": 
			ensure => present,
			groups => ["${::apache::params::group}", $group]
		}	
	}
	service{"${service}":
		alias => nagios,
		require => [
			Package["${package}"],
			Package["${plugin_package}"], 
			File["${config_dir}/nagios.cfg"]
		]
	}
}
