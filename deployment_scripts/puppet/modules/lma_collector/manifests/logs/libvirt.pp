# Class lma_collector::logs::libvirt

class lma_collector::logs::libvirt {
  include lma_collector::params
  include lma_collector::service

  $libvirt_dir       = '/var/log/libvirt'
  $libvirt_log       = 'libvirtd.log'
  $libvirt_hooks_dir = '/etc/libvirt/hooks'
  $libvirt_hook      = "${libvirt_hooks_dir}/daemon"
  $libvirt_service   = $::osfamily ? {
    'debian' => 'libvirt-bin',
    default  => 'libvirtd'
  }

  service {$libvirt_service: }

  file { $libvirt_hooks_dir:
    ensure => 'directory',
  }

  # libvirt is running as root and by default permission are restricted to
  # root user. So we need to enable other users to read this file.
  file { $libvirt_hook:
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('lma_collector/hooks_daemon.erb'),
    require => File[$libvirt_hooks_dir],
    notify  => Service[$libvirt_service],
  }

  heka::decoder::sandbox { 'libvirt':
    config_dir => $lma_collector::params::config_dir,
    filename   => "${lma_collector::params::plugins_dir}/decoders/libvirt_log.lua",
  }

  heka::input::logstreamer { 'libvirt':
    config_dir     => $lma_collector::params::config_dir,
    log_directory  => $libvirt_dir,
    file_match     => $libvirt_log,
    decoder        => 'libvirt',
    differentiator => '["libvirt"]',
    require        => Heka::Decoder::Sandbox['libvirt'],
    notify         => Class['lma_collector::service'],
  }
}
