class srv-c2c-sig-demo {

  ### Global attributes ##########################
  $server_group = "integration"
  if ! $ps1label {
    $ps1label = "integration"
  }
  $sudo_apache_admin_user = "deploy, %sigdev"
  $sudo_postgresql_admin_user = "deploy, %sigdev"
  $sudo_tomcat_admin_user = "deploy, %sigdev"

  ### OS #########################################
  include os-base
  include os-server

  ### MW #########################################
  include mw-sig
  include mw-apache
  include generic-tmpl::mw-git
  include generic-tmpl::mw-tomcat
  
  # backward compatibility
  if $postgresql_version == "8.3" {
    include generic-tmpl::mw-postgis-8-3
    include generic-tmpl::mw-postgresql-8-3
  } else {
    include generic-tmpl::mw-postgis-8-4
    include generic-tmpl::mw-postgresql-8-4
  }

  ### APP (generic) ##############################
  include app-c2c-sig
  include app-c2c-remove-ldap-support

  ### APP (specific to this server) ##############
  include app-c2c-sig-demo
  app::c2c::sadb::users{["all c2c users"]: groups => ["sigdev", "www-data"]}

}
