#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'AI::Genetic::Parallel::Population' ) || print "Bail out!\n";
}

diag( "Testing AI::Genetic::Parallel::Population $AI::Genetic::Parallel::Population::VERSION, Perl $], $^X" );
