use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;
unless( -f 'META.yml' ) {
    do 'maint/Makefile.PL.include' or die $@;
    manifest_include('script' => '.pl');
    manifest_include( 'lib/auto' => qr{[^.].*} );
}


WriteMakefile(
    NAME          => 'WWW::FatPacked',
    AUTHOR        => "Samuel Kaufman  <skaufman\@cpan.org>",
    ABSTRACT_FROM  => 'lib/WWW/FatPacked.pm',
    VERSION_FROM  => 'lib/WWW/FatPacked.pm',
    LICENSE       => "perl",
    EXE_FILES => [ "script/fatpacked.pl", "script/start.fatpacked.pl" ],
    PREREQ_PM     => {
        "Catalyst::Runtime"     => "5.90019",
        "Data::Dumper::Concise" => 0,
        "File::ShareDir"        => "1.03",
        "File::Spec"            => 0,
        "FindBin"               => 0,
        "Moose"                 => "2.0604",
        "MooseX::Types::Moose"  => "0.35",
        "Plack"                 => "1.0016",
        "YAML"                  => 0,
        "strictures"            => 1
    },
);
