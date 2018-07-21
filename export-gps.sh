#!/bin/sh
#TODO: get timecode and build a subtitle file
ffmpeg -loglevel fatal -i "$1" -map 0:2 -codec copy -f data - | perl -lne'
	BEGIN{print STDERR "lat\tlon\tspd\tazm\t0\t0\tsec\tgx\tgy\tgz"}
	for my $l (/\$([^\$]+)\$/g) {
		@F=split/,/,$l;
		$F[$_]/=1e4 for 0,1;
		$F[$_]=(unpack"c",pack"C",$F[$_])/128 for 7..9;
		print join"\t",@F;
	}
'
