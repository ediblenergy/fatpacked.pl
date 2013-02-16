package WWW::FatPacked;

our $VERSION = '0.000001'; # 0.0.1

$VERSION = eval $VERSION;

use Moose;
extends 'Catalyst';

use YAML;

my $class = __PACKAGE__;


$class->config( 
    YAML::LoadFile( $class->path_to('fatpacked.pl.yml')
);

$class->setup;

$class->meta->make_immutable;

1;
