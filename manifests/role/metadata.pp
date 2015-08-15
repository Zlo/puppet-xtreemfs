# == Role: Metadata 
#
# Ensure that node will act as XtreemFS metadata service.
#
# === Settings
#
# [*dir_host*]
#     Provide an host to where metadata and storage nodes will be connecting, defaults: <tt>$::fqdn</tt>
# [*dir_port*]
#     (Optional) A port for directory service connection
# [*dir_protocol*]
#     (Optional) A protocol for directory service connection
# [*install_packages*]
#     If set to +true+ will install packages of XtreemFS, defaults: +true+
# [*add_repo*]
#     If set to +true+ will add to system repository for XtreemFS, defaults: +true+
# [*properties*]
#     A properties hash to provide configuration options in form exactly like: 
#     http://www.xtreemfs.org/xtfs-guide-1.5/index.html#tth_sEc3.2.6
#
class xtreemfs::role::metadata (
  $dir_host         = undef,
  $dir_port         = undef,
  $dir_protocol     = undef,
  $install_packages = $xtreemfs::settings::install_packages,
  $add_repo         = $xtreemfs::settings::add_repo,
  $properties       = $xtreemfs::settings::properties,
) inherits xtreemfs::settings {
  
  include xtreemfs::internal::workflow

  if $install_packages {
    if $add_repo {
      include xtreemfs::internal::repo
    }
    include xtreemfs::internal::packages::server
  }

  $host = directory_address($dir_host, $dir_port, $dir_protocol, $xtreemfs::settings::dir_service)
  
  class { 'xtreemfs::internal::configure::metadata':
    dir_service => $host,
    properties  => $properties,
  }
  
  service { 'xtreemfs-mrc':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => Anchor[$xtreemfs::internal::configure::metadata::anchor],
    before     => Anchor[$xtreemfs::internal::workflow::service],
  }
}