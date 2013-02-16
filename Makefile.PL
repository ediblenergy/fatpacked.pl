use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'WWW-FatPacked',
  VERSION_FROM => 'lib/WWW/FatPacked.pm'
);
