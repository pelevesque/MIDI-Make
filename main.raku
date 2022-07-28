#!/usr/bin/env raku

# Make an empty MIDI file.

sub MAIN () {

    my $fh = open 'file.mid', :w, :bin;

        # HEADER
    $fh.write(Blob.new('MThd'.ords));      # header chunk ID
    $fh.write(Blob.new(0, 0, 0, 6));       # number of bytes in header
    $fh.write(Blob.new(0, 0));             # format type => 0 | 1 | 2
    $fh.write(Blob.new(0, 1));             # number of tracks
    $fh.write(Blob.new(0, 96));            # time division

        # TRACK
    $fh.write(Blob.new('MTrk'.ords));      # track chunk ID
    $fh.write(Blob.new(0, 0, 0, 4));       # number of bytes in track
    $fh.write(Blob.new(0, 0xFF, 0x2F, 0)); # track end marker

    $fh.close;
}
