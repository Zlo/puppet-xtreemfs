# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::repo {
  include xtreemfs::internal::workflow
  include xtreemfs::settings

  $repo = "${xtreemfs::settings::repobase}/${xtreemfs::settings::flavour}"

  case $::osfamily {
    /RedHat|Suse/: {
      yumrepo { 'xtreemfs':
        enabled  => 1,
        baseurl  => $repo,
        gpgcheck => 1,
        gpgkey   => "${repo}/repodata/repomd.xml.key",
        before   => Anchor[$xtreemfs::internal::workflow::repo],
      }
    }
    'Debian': {
      $key_uri = "${repo}/Release.key"
      $key = xtreemfs_download_gpg($key_uri, $xtreemfs::settings::buckup_key)
      apt::key { "xtreemfs-key":
        id      => $key,
        source  => $key_uri,
      }
      apt::source { 'xtreemfs':
        ensure      => 'present',
        release     => './',
        location    => $repo,
        repos       => '',
        include_src => false,
      }
      include apt
      include apt::update
      Exec['apt_update'] -> Anchor[$xtreemfs::internal::workflow::repo]
    }
    default: {
      fail("Unsupported operation system family: ${::osfamily}")
    }
  }

}
