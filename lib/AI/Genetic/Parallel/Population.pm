package AI::Genetic::Parallel::Population;

use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

use Carp;

=head1 NAME

AI::Genetic::Parallel::Population - population class for AI::Genetic::Parallel

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This is a collection of individuals

Perhaps a little code snippet.

    use AI::Genetic::Parallel::Population;

    my $pop = AI::Genetic::Parallel::Population->new(

        individuals => [
            AI::Genetic::Parallel::Individual->new( dna => 'AB' ),
            AI::Genetic::Parallel::Individual->new( dna => '01' ),
        ],

        #  number of intended mebers of population when full
        individual_count => 100,

        #  default sorter sorts descending based on fitness
        #  best is considered top of list
        sorter => sub {
            my $array = shift;
            return [ sort { $b->fitness <=> $a->fitness } @{$array} ];
        }

    );

    #  get individuals
    my $best_five  = $pop->best(5);
    my $worst_five = $pop->worst(5);
    my $elites     = $pop->elites;

    #  filter individuals
    $pop->keep(
        $pop->best(5),
        $pop->elites,
    );

    #  kill all individuals marked with a death_wish
    $pop->send_reaper;

=head1 METHODS

=head2 new

=over 4

=item individual_count

number of members for the populaiton

=cut

has individual_count => ( is => 'rw', isa => 'Int' );

=head2 item sorter

code-reference to define sorter behavior to define 'strongest' and 'weakest' 

=cut

has sorter => ( 

    is => 'rw', 
    isa => 'CodeRef', 
    default => sub {
        sub {
            my $array = shift;
            return [ sort { $b->fitness <=> $a->fitness } @{$array} ];
        }
    }

);

=item individuals

is an ArrayRef of ArrayRef[AI::Genetic::Parallel::Individual objects

=cut

has individuals => ( is => 'rw', isa => 'ArrayRef[AI::Genetic::Parallel::Individual]', default => sub{[]} );

=back

=head2 fittest

get the entire populaiton as sorted by sorter coderef

=cut

sub fittest {

    my $self = shift;

    return $self->sorter->( $self->individuals );

}

=head2 weakest

get the entire populaiton as reverse sorted by sorter coderef

=cut

sub weakest {

    my $self = shift;
    return [ reverse @{ $self->sorter->( $self->individuals ) } ];

}

=head2 best

get the top X as sorted by the sorter coderef

=cut

sub best {

    my $self =  shift;
    my $count = shift;

    my $individuals = $self->fittest;

    my @members;
    foreach my $idx ( 0 .. $count - 1 ) {
        push @members, $individuals->[$idx];
    }

    return \@members;

}

=head2 worst

get the worst X of the individuals as reverse sorted by the sorter coderef

=cut

sub worst {

    my $self  = shift;
    my $count = shift;

    my $individuals = $self->weakest;

    my @members;
    foreach my $idx ( 0 .. $count - 1 ) {
        push @members, $individuals->[$idx];
    }

    return \@members;

}

=head2 elites

get the individuals marked as true by the 'elite' method 

=cut

sub elites {

    my $self = shift;

    return [
        grep { $_->elite } @{ $self->individuals }
    ];

}

=head2 keep

pass in a list of references to the individuals to keep

=cut

sub keep {

    my $self = shift;
    my @groups  = @_;

    #  test each for @keeps to make sure we got an arrayref of AI::Genetic::Parallel::Individual(s)
    my $population_replacement;
    foreach my $group ( @groups ) {
        foreach my $individual ( @$group ) {

            Carp::croak( 'got a non "AI::Genetic::Parallel::Individual" object passed in' )
                if ref $individual ne 'AI::Genetic::Parallel::Individual';

            push @$population_replacement, $individual;

        }
    }

    $self->individuals( $population_replacement );

    return $self;

}

=head2 send_reaper

for all individuals with a death_with, harvest their souls

=cut

sub send_reaper {

    my $self = shift;

    $self->individuals( [ grep{ not $_->death_wish } @{$self->individuals} ] );

    return $self;

}

=head1 AUTHOR

Adam Wohld, C<< <adam at radarlabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ai-genetic-parallel-population at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-Genetic-Parallel-Population>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::Genetic::Parallel::Population


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=AI-Genetic-Parallel-Population>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/AI-Genetic-Parallel-Population>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/AI-Genetic-Parallel-Population>

=item * Search CPAN

L<http://search.cpan.org/dist/AI-Genetic-Parallel-Population/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2018 Adam Wohld.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

__PACKAGE__->meta->make_immutable;

1; # End of AI::Genetic::Parallel::Population
