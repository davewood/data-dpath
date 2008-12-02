#! /usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 9;

use 5.010;

use Data::Dumper;

BEGIN {
	use_ok( 'Data::DPath::Path' );
}

my $dpath;
my @kinds;
my @parts;
my @filters;
my @refs;

# -------------------- easy DPath --------------------

$dpath    = new Data::DPath::Path( path => '/AAA/*[0]/CCC' );
my @steps = $dpath->_steps;
@kinds   = map { $_->{kind}   } @steps;
@parts   = map { $_->{part}   } @steps;
@filters = map { $_->{filter} } @steps;
@refs    = map { ref $_       } @steps;
print Dumper(@steps);
print Dumper(\@kinds);
is_deeply(\@kinds, [qw/ROOT KEY ANYSTEP KEY/],       "kinds");
is_deeply(\@parts, ['', qw{ AAA * CCC } ],             "parts");
is_deeply(\@filters, [ undef, undef, '[0]', undef ], "filters");
is((scalar grep { $_ eq 'Data::DPath::Step' } @refs), (scalar @steps), "refs");


# -------------------- really strange DPath with lots of hardcore quoting --------------------

my $strange_path = '//A1/A2/A3/AAA/"BB BB"/BB2 BB2/"CC CC"["foo bar"]/"DD / DD"/"DD2\DD2"//EEE[ isa() eq "Foo::Bar" ]/"\"EE E2\""[ "\"affe\"" eq "Foo2::Bar2" ]/"\"EE E3\"[1]"/"\"EE E4\""[1]/"\"EE\E5\\\\\\""[1]/"\"FFF\""/"GGG[foo == bar]"/*/*[2]/XXX/YYY/ZZZ';

$dpath = new Data::DPath::Path( path => $strange_path );
@steps = $dpath->_steps;
@kinds   = map { $_->{kind}   } @steps;
@parts   = map { $_->{part}   } @steps;
@filters = map { $_->{filter} } @steps;
@refs    = map { ref $_       } @steps;

is_deeply(\@kinds, [qw/ROOT
                       ANYWHERE
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       ANYWHERE
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       KEY
                       ANYSTEP
                       ANYSTEP
                       KEY
                       KEY
                       KEY
                      /],
          "kinds2");

is_deeply(\@parts, [
                    '',
                    '',
                    'A1',
                    'A2',
                    'A3',
                    'AAA',
                    'BB BB',
                    'BB2 BB2',
                    'CC CC',
                    'DD / DD',
                    'DD2\DD2',
                    '',
                    'EEE',
                    '"EE E2"',
                    '"EE E3"[1]',
                    '"EE E4"',
                    '"EE\E5\\\\"',
                    '"FFF"',
                    'GGG[foo == bar]',
                    '*',
                    '*',
                    'XXX',
                    'YYY',
                    'ZZZ'
                   ],
          "parts2");
is_deeply(\@filters, [
                      undef,
                      undef,
                      undef,
                      undef,
                      undef,
                      undef,
                      undef,
                      undef,
                      '["foo bar"]',
                      undef,
                      undef,
                      undef,
                      '[ isa() eq "Foo::Bar" ]',
                      '[ "\"affe\"" eq "Foo2::Bar2" ]',
                      undef,
                      '[1]', '[1]',
                      undef,
                      undef,
                      undef,
                      '[2]',
                      undef,
                      undef,
                      undef,
                     ],
          "filters2");
is((scalar grep { $_ eq 'Data::DPath::Step' } @refs), (scalar @steps), "refs2");
