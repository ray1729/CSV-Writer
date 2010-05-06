#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use File::Temp;
use Readonly;

Readonly my @DATA => (
    [ "a", "b,c", "d", 1 ],
    [ "e", "f", "g", 2 ],
    [ "h", "i", "j", 3 ],
);

Readonly my $CSV => <<'EOT';
a,"b,c",d,1
e,f,g,2
h,i,j,3
EOT

use_ok 'CSV::Writer';

{    
    ok my $csv = CSV::Writer->new(), 'no args constructor';
    isa_ok $csv, 'CSV::Writer', '...the object it returns';
    can_ok $csv, 'write';
    can_ok $csv, '_output';
    isa_ok $csv->_output, 'IO::Handle';
    can_ok $csv, '_csv';
    isa_ok $csv->_csv, 'Text::CSV_XS';
    can_ok $csv, 'csv_opts';
    isa_ok $csv->csv_opts, 'HASH';
}

{
    my $tmp = File::Temp->new;
    ok my $csv = CSV::Writer->new( output => $tmp ), 'output to tmp file';

    for ( @DATA ) {
        ok $csv->write( $_ ), "print \[@{$_}\]";
    }

    $tmp->seek(0,0);
    my $file_contents = do { local $/ = undef; $tmp->getline };
    is $file_contents, $CSV, 'file contents';
}

{
    my $csv_str;
    ok my $csv = CSV::Writer->new( output => \$csv_str ), 'output to string';
    for ( @DATA ) {
        ok $csv->write( @$_ ), "print @{$_}";        
    }

    is $csv_str, $CSV, 'string contents';
}

{
    my $csv_str;
    ok my $csv = CSV::Writer->new( output => \$csv_str, csv_opts => { eol => "\n", quote_char => q{'} } ), 'specify csv options';
    for ( @DATA ) {
        ok $csv->write( $_ ), "write \[@{$_}\]";        
    }
    ( my $expected_str = $CSV ) =~ s/"/'/g;
    is $csv_str, $expected_str, 'string contents';
}

{
    my $csv_str;
    ok my $csv = CSV::Writer->new( output => \$csv_str, columns => [ qw( a b d ) ] ), 'specify columns';
    ok $csv->write( { a => 1, b => 2, c => 3, d => 4, e => 5 } ), 'write hashref';
    is $csv_str, "1,2,4\n", 'string contents';
}

{
    ok my $csv = CSV::Writer->new, 'no options constructor';
    throws_ok { $csv->write( { a => 1, b => 2 } ) } qr/must specify columns when writing a hash/;
}

done_testing();

    




