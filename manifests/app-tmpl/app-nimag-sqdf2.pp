class app-nimag-sqdf2 {

  include mysql::server
  include openldap::server::ssl
  include monitoring::ldap


  file {"/etc/ldap/config.ldif":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    source  => "puppet:///modules/avocatsch/ldap/config.ldif",
    require => Class["openldap::server::ssl"],
  }
  
  file {"/etc/ldap/ssl/ldap.crt":
    ensure  => present,
    mode    => 0644,
    owner   => openldap,
    group   => openldap,
    source  => "puppet:///modules/avocatsch/ldap/ssl/ldap.crt",
    require => Class["openldap::server::ssl"],
    notify  => Service["slapd"],
  }
  
  file {"/etc/ldap/ssl/ldap.key":
    ensure  => present,
    mode    => 0600,
    owner   => openldap,
    group   => openldap,
    source  => "puppet:///modules/avocatsch/ldap/ssl/ldap.key",
    require => Class["openldap::server::ssl"],
    notify  => Service["slapd"],
  }
  
  file {"/etc/ldap/DB_CONFIG":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    source  => "puppet:///modules/avocatsch/ldap/DB_CONFIG",
    require => Class["openldap::server::ssl"],
  }
  
  augeas {"configure slapd defaults":
    context => "/files/etc/default/slapd/",
    notify  => Service["slapd"],
    changes => ["set SLAPD_SERVICES  'ldap://127.0.0.1:389/'"],
    require => Class["openldap::server::ssl"],
  }
  
  augeas {"configure ldap client":
    context => "/files/etc/ldap/ldap.conf",
    changes => [
      "set BASE 'dc=${slapd_domain}'",
      "set URI 'ldap://localhost'"
    ],
  }

  user {"osubilia":
    ensure => present,
    shell  => "/bin/bash",
    home   => "/home/osubilia",
    groups => "www-data",
    managehome => true,
  }

  ssh_authorized_key {"olivier.subilia@avocats-ch.ch":
    ensure => present,
    user   => "osubilia",
    type   => "ssh-rsa",
    key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEA0ceIdQBMkyvmrqYHY9OA4hOcsQekIr6aMh3jxpaGGHatZgcPN7Pe3vXC5ivLidlKVuDcfY3eDEywEMQpo+H+gdjsMvrs/k+vOziXQegtQ1OCo5mhmP1nByeG9joRQErHYGrEZfxdh9wz52j44OubEWsD/6Sw01GSDnU2G34/Q0Zdx/4knll/qpoEKqHFP1CfgZqsWmquZALP02s97cNPg8Yzya+unk7X149Pr0aiP4LNIWvwej8wFi+P/i6DwGNAtx/jOsBFkdBHhn6M77+I3NSY95V2c1gyocsXR3T1scBu34IYRGT3q7Whv1uMJwpquPgTitTVV01moFI4rviX7Q==",
  }

  common::concatfilepart {"sudoers.osubilia":
    ensure => present,
    file   => "/etc/sudoers",
    content => "osubilia ALL=(ALL) /usr/sbin/a2ensite, /usr/sbin/a2enmod, /usr/sbin/a2dismod, /usr/sbin/a2dissite\n",
  }

  file {"/etc/apache2/sites-available":
    ensure => directory,
    owner  => osubilia,
    group  => osubilia,
    mode   => 0755,
  }

  file {"/var/www/vhosts":
    ensure => directory,
    owner  => osubilia,
    group  => www-data,
    mode   => 0755,
  }

}