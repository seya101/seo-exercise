class monitor_setup {
  package { ['vim', 'curl', 'git']:
    ensure => 'installed',
  }

  user { 'monitor':
    ensure     => 'present',
    managehome => true,
    home       => '/home/monitor',
    shell      => '/bin/bash',
  }

  file { '/home/monitor/scripts':
    ensure => 'directory',
    owner  => 'monitor',
    group  => 'monitor',
    mode   => '0755',
  }

  exec { 'download_memory_check_script':
    command => '/usr/bin/wget -O /home/monitor/scripts/memory_check https://raw.githubusercontent.com/seya101/seo-exercise/path/to/memory_check_script',
    creates => '/home/monitor/scripts/memory_check',
    require => File['/home/monitor/scripts'],
  }

  file { '/home/monitor/src':
    ensure => 'directory',
    owner  => 'monitor',
    group  => 'monitor',
    mode   => '0755',
  }

  file { '/home/monitor/src/my_memory_check':
    ensure  => 'link',
    target  => '/home/monitor/scripts/memory_check',
    require => Exec['download_memory_check_script'],
  }

  cron { 'memory_check_cron':
    command => '/home/monitor/src/my_memory_check',
    user    => 'monitor',
    minute  => '*/10',
  }

  exec { 'set_time_zone':
    command => '/usr/bin/timedatectl set-timezone Asia/Manila',
    unless  => '/usr/bin/timedatectl | /bin/grep "Time zone: Asia/Manila"',
  }

  exec { 'set_hostname':
    command => '/usr/bin/hostnamectl set-hostname bpx.server.local',
    unless  => '/usr/bin/hostnamectl | /bin/grep "Static hostname: bpx.server.local"',
  }
}
