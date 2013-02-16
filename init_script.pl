#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
use FindBin;
use Daemon::Control;
Daemon::Control->new({
    name        => "fatpacked.pl",
    lsb_start   => '$syslog $remote_fs',
    lsb_stop    => '$syslog',
    lsb_sdesc   => 'fatpacked.pl',
    lsb_desc    => 'fatpacked.pl controls the fatpacked.pl site',
    path        => "$FindBin::Bin/init_script.pl",
    init_config => "/opt/fatpacked.pl/perl_env",
    program     => '/opt/fatpacked.pl/perl5/bin/fatpacked.pl',
    program_args => [ '--port', '3001'],
 
    pid_file    => '/opt/fatpacked.pl/var/run/fatpacked.pl.pid',
    stderr_file => '/var/log/fatpacked.pl/stderr.out',
    stdout_file => '/var/log/fatpacked.pl/stdout.out',
 
    fork        => 2,
 
})->run;
