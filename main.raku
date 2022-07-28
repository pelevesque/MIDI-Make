#!/usr/bin/env raku

# Make an empty MIDI file.

constant $ENDIANNESS = BigEndian;

subset NonNegativeInt of Int where * ≥ 0;
sub write_2-bytes(NonNegativeInt $int) { Buf.write-uint16(0, $int, $ENDIANNESS) }
sub write_4-bytes(NonNegativeInt $int) { Buf.write-uint32(0, $int, $ENDIANNESS) }

sub MAIN () {

    my $buf = Buf.new();

        # HEADER
    $buf.append('MThd'.ords);      # header chunk ID
    $buf.append(write_4-bytes(6)); # number of bytes in header
    $buf.append(write_2-bytes(0)); # format type => 0 | 1 | 2
    $buf.append(write_2-bytes(1)); # number of tracks
    $buf.append(0, 96);            # time division

        # TRACK
    $buf.append('MTrk'.ords);      # track chunk ID
    $buf.append(write_4-bytes(4)); # number of bytes in track
    $buf.append(0, 0xFF, 0x2F, 0); # track end marker

    spurt 'file.mid', $buf;
}
