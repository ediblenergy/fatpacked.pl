#!/usr/bin/env perl
use strictures 1;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Module::Pluggable search_path => [qw(WWW::FatPacked)];

require_ok( $_ ) for __PACKAGE__->plugins;

done_testing;

