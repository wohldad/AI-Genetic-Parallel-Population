#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 45;

use Data::Dumper;

use AI::Genetic::Parallel::Population;
use AI::Genetic::Parallel::Individual;


can_ok( 'AI::Genetic::Parallel::Population', 'new', 'population', 'fittest', 'weakest', 'best', 'worst', 'elites', 'keep', 'send_reaper' );


#  fill up a population
my $pop = AI::Genetic::Parallel::Population->new(
    population => [
        AI::Genetic::Parallel::Individual->new( dna => '000' ),
        AI::Genetic::Parallel::Individual->new( dna => '001' ),
        AI::Genetic::Parallel::Individual->new( dna => '010' ),
        AI::Genetic::Parallel::Individual->new( dna => '011' ),
        AI::Genetic::Parallel::Individual->new( dna => '100', elite => 1 ),
        AI::Genetic::Parallel::Individual->new( dna => '101' ),
        AI::Genetic::Parallel::Individual->new( dna => '110' ),
        AI::Genetic::Parallel::Individual->new( dna => '111' ),
    ],
);


#  did we get the object we expect
isa_ok( $pop, 'AI::Genetic::Parallel::Population' );


#  for each individual, each fitness should be undefined
foreach my $individual ( @{ $pop->population } ) {
    is( $individual->fitness, undef, "member with DNA " . $individual->dna . " is not defined" );
}


#  set each fitness and check that it returns a value
foreach my $idx ( 0 .. 7 ) {
    is( $pop->population->[$idx]->fitness($idx), $idx, "set fitness for DNA " . $pop->population->[$idx]->dna . " to $idx" );
}


#  check to see that all the fitnesses are there
foreach my $idx ( 0 .. 7 ) {
    is( $pop->population->[$idx]->fitness, $idx, "got fitness for DNA " . $pop->population->[$idx]->dna . " as $idx" );
}


#  set one of the DNA's as elite
is( $pop->population->[0]->elite( 1 ), 1, "set DNA 000 to elite" );


#  get the elites 
is( $pop->elites->[0]->dna, '000', "DNA 000 is elite" );
is( $pop->elites->[1]->dna, '100', "DNA 100 is elite" );


#  get the best fitness
is( $pop->fittest->[0]->dna, '111', "DNA 111 is best fitness"        );
is( $pop->fittest->[1]->dna, '110', "DNA 110 is second best fitness" );
is( scalar @{$pop->fittest},   '8', "got 8 fittest results"          );


#  get weakest fitness
is( $pop->weakest->[0]->dna, '000', "DNA 000 is best fitness"        );
is( $pop->weakest->[1]->dna, '001', "DNA 001 is second best fitness" );
is( scalar @{$pop->weakest},   '8', "got 8 weakest results"          );


#  get best 2
is( $pop->best(2)->[0]->dna, '111', "got best DNA 111"     );
is( $pop->best(2)->[1]->dna, '110', "got 2nd best DNA 110" );
is( scalar @{$pop->best(2)},   '2', "got 2 best results"   );


#  get worst 2
is( $pop->worst(2)->[0]->dna, '000', "got worst DNA 000"     );
is( $pop->worst(2)->[1]->dna, '001', "got 2nd worst DNA 001" );
is( scalar @{$pop->worst(2)},   '2', "got 2 worst results"   );

#  keep best 2 and elites, discard the rest
isa_ok( $pop->keep( $pop->best(2), $pop->elites ), 'AI::Genetic::Parallel::Population' );
is( scalar @{$pop->population}, '4',               'kept best 4'                       );


#  test the grimm reaper
$pop->population->[0]->death_wish(1);
isa_ok( $pop->send_reaper,           'AI::Genetic::Parallel::Population'     );
is( scalar @{$pop->population}, '3', 'we killed on member of the populaiton' );

