# Minimal nagios installation

class check_mk::nagios ( 
	$version,
	$user,
	$group,
	$apache_user,
	$apache_group
) inherits check_mk::nagios::config { 
	include check_mk::pnp4nagios
	include apache::params

	package{"${package}": }
	package{"${pluginspackage}": }
	file{"${config_dir}": mode => 644, ensure => directory }
	file{"${config_dir}/nagios.cfg": mode => 644, content => template("check_mk/nagios.cfg.erb")}
	file{"$commandfile": mode => 640, owner => $user, group => $group}

	if defined(User[$apache_user]) {
		User[$apache_user] { groups +> $group }
	} else { 
		user{$apache_user: 
			ensure => present,
			groups => [$apache_group, $group]
		}	
	}
	service{"${service}":
		alias => nagios,
		require => [
			Package["${package}"],
			Package["${pluginspackage}"], 
			File["${config_dir}/nagios.cfg"]
		]
	}
}
