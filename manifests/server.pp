# Usage:
# inclue check_mk::server
# 
# Note the lack of parameters to the class, this is due to puppet 3.x hiera integration. See the README for more details

class check_mk::server(
	$conf_dir="/etc/check_mk",
	$tarball_url
){

	class {nagios: }
	apache::module{'python': install_package => true }
	include apache::params

	$tarball_name = basename($tarball_url)
	$tarball_dir_name = regsubst($tarball_name, '\.tar\.gz$', "")
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
		notify => Exec[check_mk_refresh],
		require => Package[pnp4nagios]
	}
	exec { 'check_mk_refresh':
        command => "/usr/local/bin/check_mk -O",
        refreshonly => true,
    }
    file {["${conf_dir}", "${conf_dir}/conf.d"]:
    	ensure => directory,
    	mode => 644
    }
    file {"${conf_dir}/main.mk":
    	mode => 644,
    	content => template("check_mk/main.mk.erb"),
    	notify => Exec[check_mk_refresh]
	}

	# ping needs to be run as root
	file{"/usr/lib/nagios/plugins/check_icmp":
		mode => 4755
	}

	file{"${check_mk::nagios::config::htpasswdfile}":
		mode => 0600,
		owner => $::apache::params::user,
		source => "puppet:///modules/check_mk/htpasswd.users"
	}

    Check_mk::Host<<| tag == "check_mk::agent::${::environment}" |>>

 #    apache::vhost{"check_mk": 
 #    	docroot => "/usr/share/check_mk/web/htdocs",
 #    	template => "check_mk/apache_vhost.conf.erb",
 #    	ssl => false,
 #    	port => 80
	# }
}
