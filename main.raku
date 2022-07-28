#!/usr/bin/env raku

# Make an empty MIDI file.

constant $ENDIANNESS = BigEndian;

my %bytes =
    'meta-event'   => 0xFF,
    'end-of-track' => 0xF2,
;

sub write_2-bytes(UInt $int) { Buf.write-uint16(0, $int, $ENDIANNESS) }
sub write_4-bytes(UInt $int) { Buf.write-uint32(0, $int, $ENDIANNESS) }

sub make-header($buf, $format, $num-tracks, $time-division) {
    $buf.append: 'MThd'.ords;                   # header chunk ID
    $buf.append: write_4-bytes(6);              # number of bytes in header
    $buf.append: write_2-bytes($format);        # format type => 0 | 1 | 2
    $buf.append: write_2-bytes($num-tracks);    # number of tracks
    $buf.append: write_2-bytes($time-division); # time division
}

sub make-track($buf) {
    $buf.append: 'MTrk'.ords;            # track chunk ID
    $buf.append: write_4-bytes(4);       # number of bytes in track
    $buf.append: 0;                      # delta time
    $buf.append: %bytes{'meta-event'};   # meta event marker
    $buf.append: %bytes{'end-of-track'}; # end of track event
    $buf.append: 0;                      # end of track data
}

sub MAIN () {
    my $buf = Buf.new();

    make-header($buf, 0, 1, 96);
    make-track($buf);

    spurt 'file.mid', $buf;
}
