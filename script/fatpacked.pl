#!/usr/bin/env perl
use strictures 1;
use Plack::Runner;
use Plack::Builder;
use FindBin;
use lib "$FindBin::Bin/../lib";
use WWW::FatPacked;

my $runner = Plack::Runner->new;
$runner->parse_options(@ARGV);
$runner->run(
    builder {
        WWW::FatPacked->psgi_app(@_);
    } );
