#!/Users/brian/bin/perls/perl5.14.2
use v5.10.1;
use utf8;
use strict;
use warnings;
no warnings 'uninitialized';

use Email::Simple;

my $dir = $ARGV[0] || '/Users/brian/Desktop';

my @files = glob( "$dir/perl.jobs/*.txt" );

my %date;
my %Seen;
my $duplicates;
my $files;

foreach my $file ( @files ) {
	$files++;
	my $text = do { local( @ARGV, $/ ) = $file; <> };
	my $email = Email::Simple->new( $text );

	next unless $email->header( 'From' ) eq 'jobs-admin@perl.org (Perl Jobs)';

	my $body = $email->body;

	my( $posting ) = $body =~ m|^Online URL for this job: http://jobs\.perl\.org/job/(\d+)|m;
	$duplicates++ if $Seen{$posting} > 0;
	next if $Seen{$posting}++;
	
	my( $month_name, $day, $year ) = $body =~ /^Posted: \s+ ([a-z]+) \s+ (\d+), \s+ (\d+)/mix;
	state $months = [ qw(January February March April May June July August September October November December) ];
	state $name2num = { map { state $n = 1; $_, $n++ } @$months };
	
	warn "Unrecognized month [$month_name]\n" unless exists $name2num->{$month_name};
	my $month = $name2num->{$month_name};

	$date{_count}++;
	$date{$year}{_count}++;
	$date{$year}{$month}{_count}++;
	$date{$year}{$month}{$day}{_count}++;
	}

say "File count is $files";
say "Total posts is $date{_count}";
say "Duplicate count is $duplicates";
say "Uncounted is ", $files - $date{_count} - $duplicates;

say "-" x 90;

printf "%4s | %5s |  %4s  %4s  %4s  %4s  %4s  %4s  %4s  %4s  %4s  %4s  %4s  %4s\n",
        'Year', 'Total', qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

say "-" x 90, "\n";

foreach my $year ( sort { $a <=> $b } grep { ! /^_/ } keys %date ) {
        my $total = $date{$year}{_count};
        printf "%4d | %5d |  %4d  %4d  %4d  %4d  %4d  %4d  %4d  %4d  %4d  %4d  %4d  %4d\n",
                $year, $total, map { $_->{_count} // 0 } @{ $date{$year} }{ ( 1 .. 12 ) };
        
        }

=pod

foreach my $year ( sort { $a <=> $b } keys %date ) {
	foreach my $month ( sort { $a <=> $b } grep { ! /^_/ } keys %{ $date{$year} } ) {
		printf "%4d-%02d: %5d\n", $year, $month, $date{$year}{$month}{_count};
		}
	}

=cut

