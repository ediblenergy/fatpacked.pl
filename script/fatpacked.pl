use strictures 1;
use Plack::Builder;
use FindBin;
use lib "$FindBin::Bin/../lib";
use WWW::FatPacked;

builder {
    WWW::FatPacked->psgi_app(@_);
};
