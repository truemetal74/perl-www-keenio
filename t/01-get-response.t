#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Sys::Hostname;

plan tests => 4;

BEGIN {
    use_ok( 'WWW::KeenIO' ) || print "Bail out!\n";
}

my $class = 'WWW::KeenIO';
my $obj = $class->new({
    project => '54d51b7f96773d3a427b5a76',
    api_key => 'dba21e199cf7534d26b57dbb66d6a3f7db96786c7b0e92f9e3effb963b3a7b1eca958a8e169377396850c9225ec168c5dfd9d641d326685e944317e0e77cf354d9d16b332a55dc6f26775339258cfb6aa98cac699c4a81bf534acb15ba727ed2da18f09cf8a84a8b79d15fae559d95f3',
    write_key => 'f86a7e890bd34a6f807e595d78398346acb9a71402d6ba7a8d3c132262430b59e2d04d0d295fbd567252e925b3b2f76f0522336b58eabcfcf257f85dd8d6203d56cd1fe093bfac9f94cf95f2ed4917075793f58580a3ff3a66860faf627e0fad07e0ab3e6d6ad937984df4df9bc32ce8'
   });
isa_ok($obj, $class, 'Create object');

my $r;
ok( $r = $obj->put('tests',
                   { hostname =>  hostname(), time => q{}.localtime() } ),
    'Insert object');
$obj->project('aaa'); # fake
ok( ! ($r = $obj->put('tests',
                   { } )),
    'Handle insertion error');

