#!/usr/bin/perl
use warnings;
use strict;

use autodie;
use charnames ':full';
use Getopt::Long;
use IPC::Open3;
use Symbol 'gensym';

my $mode = "tsv";

GetOptions(
	'mode=s' => \$mode,
) or die "Usage: $0 [--mode=tsv|srt] <files.MP4> ...\n";

my %export = (
	tsv => sub {
		print((join "\t", qw(lat lon spd azm 0 0 sec gx gy gz)), "\n");
		print((join "\t", @$_), "\n") for @_;
	},
	srt => sub {
		my $i = 0;
		for (@_) {
			print "$i\n";
			printf "%02d:%02d:%02d,000 --> %02d:%02d:%02d,000\n",
				$i/3600, $i%3600/60, $i%60, ($i+1)/3600, ($i+1)%3600/60, ($i+1)%60;
			printf "%.4f%s %.4f%s; %g km/h; %.0f\N{DEGREE SIGN}; a=(%.2f, %.2f, %.2f) g\n\n",
				$_->[0], $_->[0] >=0 ? 'N' : 'S',
				$_->[1], $_->[1] >=0 ? 'E' : 'W',
				@{$_}[2, 3, 7..9];
			$i++;
		}
	},
);

die "Invalid mode $mode" unless exists $export{$mode};

for my $file (@ARGV) {
	my ($sin, $sout, $serr); $serr = gensym;
	
	# TODO: actually get timecode information from the stream
	my $pid = open3($sin, $sout, $serr, qw(ffmpeg -loglevel fatal -i), $file, qw(-map 0:2 -codec copy -f data -));
	close $sin;
	close $serr;

	my $gps = do { local $/; <$sout>; };
	close $sout;
	waitpid $pid, 0;

	(my $target = $file) =~ s/\.MP4$/.$mode/i;
	open my $out, ">:utf8", $target;
	select $out;

	$export{$mode}->(
		map {
			my @F = split /,/;
			$F[$_] /= 1e4 for 0,1; # latitude and longitude
			# acceleration is a signed byte, with range of +/- 1 gee (?)
			$F[$_] = (unpack"c", pack"C", $F[$_])/128 for 7..9;
			\@F;
		} ($gps =~ /\$([^\$]+)\$/g)
	);

	select STDOUT;
}
