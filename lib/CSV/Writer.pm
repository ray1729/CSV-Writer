package CSV::Writer;

# ABSTRACT: wrapper around Text::CSV_XS to reduce boilerplate when writing CSV files

use Moose;
use MooseX::Types::IO 'IO';
use Text::CSV_XS;
use namespace::autoclean;

has output => (
    isa      => 'IO',
    accessor => '_output',
    coerce   => 1,
    default  => sub { IO::Handle->new_from_fd( \*STDOUT, 'w' ) }
);

has csv_opts => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { { eol => $/ } }
);

has csv => (
    isa        => 'Text::CSV_XS',
    accessor   => '_csv',
    lazy_build => 1
);

has columns => (
    traits  => [ 'Array' ],
    handles => {
        columns     => 'elements',
        has_columns => 'count',
            
    },
    default => sub { [] },        
);

sub _build_csv {
    Text::CSV_XS->new( shift->csv_opts );
}

sub write {
    my $self = shift;

    my $data;

    if ( @_ == 1 and ref $_[0] eq 'ARRAY' ) {
        $data = shift @_;
    }
    elsif ( @_ == 1 and ref $_[0] eq 'HASH' ) {
        confess "must specify columns when writing a hash"
            unless $self->has_columns;        
        $data = [ @{ $_[0] }{ $self->columns } ];
    }
    else {
        $data = \@_;
    }

    $self->_csv->print( $self->_output, $data )
        or confess "Failed to write data to CSV: $!";                    
}

1;

__END__

=pod

=head1 NAME

CSV::Writer

=head1 SYNOPSIS

  use CSV::Writer;

  my $csv = CSV::Writer->new();
  $csv->write( @data );

=head1 DESCRIPTION

Wrapper around Text::CSV_XS to reduce boilerplate when writing CSV files.

=head1 METHODS

=head2 new

Constructor, accepts a hash ref or list of key/value pairs:

=over 4

=item output

The filename or L<IO::Handle> object that output will be written to.

=item csv_opts

A hash reference of options for the L<Text::CSV_XS> constructor.

=back

=head2 write( I<@data> )

Write I<@data> as CSV to the output stream

=head1 SEE ALSO

L<Text::CSV_XS>, L<Moose>, L<MooseX::Types::IO>

=head1 AUTHOR

Ray Miller E<lt>rm7@sanger.ac.ukE<gt>

=head1 BUGS

None reported...yet!

=cut

