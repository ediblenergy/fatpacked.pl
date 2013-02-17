#!/usr/bin/env perl
use strictures 1;
use Plack::Runner;
use Plack::Builder;
use FindBin;
use File::ShareDir qw[ dist_dir ];
use lib "$FindBin::Bin/../lib";
use WWW::FatPacked;

my $dist_dir = dist_dir("WWW-FatPacked");

my $runner = Plack::Runner->new;
$runner->parse_options(@ARGV);
$runner->run(
    builder {
        enable(
            "Plack::Middleware::ErrorDocument",
            500 => "$dist_dir/error_doc/500.html",
            404 => "$dist_dir/error_doc/404.html"
        );
        WWW::FatPacked->psgi_app(@_);
    } );
