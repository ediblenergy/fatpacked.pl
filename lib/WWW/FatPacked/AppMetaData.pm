package WWW::FatPacked::AppMetaData;

use strictures 1;
use Moose;
use MooseX::Types::Moose qw[ ArrayRef Str ];

my $class = __PACKAGE__;

has source_url => (
    is       => 'ro',
    required => 1,
    isa      => Str,
);

has subdomains_to_resolve => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef [Str],
);

has doc_url => (
    is       => 'ro',
    isa      => Str,
    required => 0,
);

$class->meta->make_immutable;

1;
