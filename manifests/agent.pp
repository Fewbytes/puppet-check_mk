class check_mk::agent(
		$host_tags = [],
		$package_name,
		$package_url,
		$binary
	) { 
	
	$package_filename = basename($package_url)
	$pkg_provider = $::osfamily ? {
		"Debian" => "dpkg",
		"RedHat" => "rpm"
	}	
	file{"/opt/check-mk": ensure => directory }
	->
	exec {"wget ${package_url}": 
		cwd => "/opt/check-mk",
		creates => "/opt/check-mk/${package_filename}",
		path => "/bin:/usr/bin:/usr/local/bin"
	}
	~>
	package{$package_name: ensure => latest, provider => "$pkg_provider", source => "/opt/check-mk/${package_filename}" }
	->
	xinetd::service{"check_mk":
		service_type => UNLISTED,
		port => 6556,
		socket_type => stream,
		protocol => tcp,
		user => root,
		server => "$binary",
	}
	
	# TODO: consider migration to nodesearch
	@@check_mk::host{$fqdn: host_tags => $host_tags, tag => "check_mk::agent::${::environment}" }

}
