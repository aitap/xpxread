# What is this?

If you have and XPX G525-STR dash cam (which seems to be an Subini STR XT-8 clone), you might want to export the GPS data from the video files it produces.

The videos are fairly usual MPEG4 with AVC and AAC and a third stream of type "scene description" in "mp4s" format, according to metadata. If you export it using `ffmpeg`, you'll see that it's just batches of 10 numbers joined by commas `,` and wrapped in pairs of `$...$`. Matching those numbers with speed, coordinates and acceleration from official software is fairly straightforward (there's three additional columns, two of which are always 0 and the third seems to be showing seconds of local time).

# How to use?

Make sure you have `ffmpeg` installed (the script relies on having it in `PATH`, sorry). You can choose between exporting `\t`-separated tables (`tsv` mode; no time information yet, sorry) and subtitles in SRT format (`srt` mode; with time information inferred from the fact that GPS information is emitted once per second).

Run:

    perl xpxread.pl -m chosen_mode path/to/file.MP4 path/to/file.MP4 ...

The script with produce corresponding files with the same name but different extension near the originals.
