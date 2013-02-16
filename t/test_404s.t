use strictures 1;
use Test::More;
use LWP::UserAgent;
use File::ShareDir;
use FindBin;
use Data::Dumper::Concise;
use lib "$FindBin::Bin/../lib";
use Catalyst::Test 'WWW::FatPacked';
ok my $mapping = WWW::FatPacked->controller("Root")->subdomain_app;
while ( my ( $name, $app ) = each(%$mapping) ) {
    for ( @{ $app->subdomains_to_resolve } ) {
        my $domain = "$_.fatpacked.pl";
        my $res = request( '/', { host => $domain } );
        ok $res->is_redirect, "requesting $domain";
        is $res->header('location'), $app->source_url,'location redirect matches source url';
    }
}
done_testing;
