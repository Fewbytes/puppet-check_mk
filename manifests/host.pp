define check_mk::host(
	$host_ip = $ipaddress
) {
	file{"/etc/check_mk/conf.d/${title}.mk":
		tag => "check_mk::agent::${environment}",
		content => template("check-mk/server_conf.mk.erb"),
		mode => 644,
		notify => Exec["check-mk-inventory-${title}"]
	}
	exec{"check-mk-inventory-${title}":
		tag => "check_mk::agent::${environment}",
		refreshonly => true,
		command => "/usr/local/bin/check_mk -I ${title}",
		notify => Exec["check_mk_refresh"]
	}
}
