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
        enable(
            "Plack::Middleware::ErrorDocument",
            500 => "$FindBin::Bin/../error_doc/500.html",
            404 => "$FindBin::Bin/../error_doc/404.html"
        );
        WWW::FatPacked->psgi_app(@_);
    } );
