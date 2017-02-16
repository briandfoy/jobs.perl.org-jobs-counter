#!/Users/brian/bin/perls/perl5.14.2
use v5.10;
use utf8;
use strict;
use warnings;

use File::Spec::Functions;
use Net::NNTP;
use IO::Interactive qw(interactive);

select( interactive() );

my $nntp = Net::NNTP->new('nntp.perl.org');
my( $count, $first, $last ) = $nntp->group( 'perl.jobs' );
say "$count, $first, $last";

my $dir = 'perl.jobs';
mkdir $dir, 0755 unless -d $dir;

my %skips = map { $_, undef } qw(
	2079
	3338
	);

foreach my $i ( $first .. $last ) {
	next if exists $skips{$i};
	my $file = catfile( $dir, "$i.txt" );
	next if -s $file;
	open my $fh, '>', $file;
	my $article = $nntp->article( $i, $fh );
	close $fh;
	say $i;
	sleep 1;
	}

$nntp->quit;

if( $ENV{PERL_JOBS_COMMIT} ) {
	system "git add --quiet perl.jobs";
	system "git commit --quiet -a -m 'Added the latest Perl jobs posts'";
	system "git push --quiet";
	}

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AVAILABILITY

=head1 AUTHOR

brian d foy C<< <brian.d.foy@gmail.com> >>

=head1 COPYRIGHT

Copyright 2012-2013, brian d foy C<< <brian.d.foy@gmail.com> >>

=cut




