#!/usr/bin/perl

use strict;
use warnings;
     
use 5.008;
     
use ExtUtils::MakeMaker;
WriteMakefile
  (
      NAME         => 'WWW::KeenIO',
      VERSION_FROM => 'lib/WWW/KeenIO.pm',
      PREREQ_PM    => {
          'Carp' => 0,
          'Data::Dumper' => 0,
          'JSON::XS' => 0,
          'Mouse' => '2.0.0',
          'Readonly' => 0,
          'REST::Client' => '273',
          'Scalar::Util' => 1,
          'URI' => 0,
      },
      BUILD_REQUIRES => {
        'Test::More' => '0.47',
        'Test::Mouse' => 0,
        'Sys::Hostname' => 0
      },
     );
