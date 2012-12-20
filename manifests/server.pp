class check-mk::server(
	$conf_dir="/etc/check_mk",
	$tarball_url
){
	class {nagios: template => "check-mk/nagios.cfg.erb"}
	apache::module{'wsgi': install_package => true }

	$tarball_name = basename($tarball_url)
	$tarball_dir_name = regsubst($tarball_name, "\.tar\.gz$", "")
	$work_dir = "/opt/check-mk"

	exec{"wget $tarball_url && tar -xzf $tarball_name": 
		creates => "${work_dir}/${tarball_dir_name}" ,
		cwd => $work_dir
	}
	->
	exec{'check_mk setup':
		command => "${work_dir}/${tarball_dir_name}/setup.sh --yes",
		cwd => "${work_dir}/${tarball_dir_name}",
		creates => "/usr/lib/check_mk/livestatus.o",
		environment => ["bindir=/usr/local/bin"],
		notify => Exec[check_mk_refresh]
	}
	exec { 'check_mk_refresh':
        command => "/usr/local/bin/check_mk -O",
        refreshonly => true,
    }
    file {["$conf_dir", "${conf_dir}/servers.d"]:
    	ensure => directory,
    	mode => 644
    }
    File<<| tag == "check_mk::agent::${::environment}" |>>
    Exec<<| tag == "check_mk::agent::${::environment}" |>>
}