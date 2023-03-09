unit module MIDI::Make;

subset UInt4  of UInt where * ≤ 15;
subset UInt7  of UInt where * ≤ 127;
subset UInt8  of UInt where * ≤ 255;
subset UInt15 of UInt where * ≤ 32767;
subset UInt16 of UInt where * ≤ 65535;
subset UInt24 of UInt where * ≤ 16777215;
subset UInt28 of UInt where * ≤ 268435455;
subset UInt32 of UInt where * ≤ 4294967295;

    # Operator: ♩
    # Transforms QPM to μsPQ.
    # QPM = Quarter notes per minute.
    # μsPQ = Microseconds per quarter note.
    # ➤ say ♩60; «1000000␤»
subset QPM of Numeric where 0.22351741874 ≤ * ≤ 60000001;
sub prefix:<♩> (QPM $QPM) is export(:MANDATORY) {
    (60000000 / $QPM).floor
}

    # Operator: \
    # Helps to write human-like time signatures.
    # ➤ say (2\8).MIDI-nominator; «2␤»
    # ➤ say (2\8).MIDI-denominator; «3␤»
my constant @pow2 = 2 «**« ^256; # 2⁰ → 2²⁵⁵
subset Pow2 of UInt where * ~~ any @pow2;
sub infix:<\\> (
    UInt8 $numerator,
    Pow2 $denominator,
) is export(:MANDATORY) {
    class Time-Signature {
        has $.numerator;
        has $.denominator;
        method MIDI-numerator { $!numerator }
        method MIDI-denominator { Int($!denominator.log(2)) }
    }
    Time-Signature.new: :$numerator, :$denominator;
}

sub write_2-bytes (UInt16 $n) { Buf.write-uint16(0, $n, BigEndian) }
sub write_4-bytes (UInt32 $n) { Buf.write-uint32(0, $n, BigEndian) }

class File is export(:shortnames) {
    subset format where * ~~ 0 | 1 | 2;
    subset time-division where * ~~ 'quarter' | 'frame';
    subset FPS where * ~~ 24 | 25 | 29.97 | 30;

    has format $.format = 1;
    has time-division $.time-division = 'quarter';
    has UInt15 $.PPQ = 48; # Pulses per quarter note.
    has FPS    $.FPS = 24; # Frames per second.
    has UInt8  $.PPF = 4;  # Pulses per frame.

        # Getters.
    multi method format { $!format }
    multi method time-division { $!time-division }
    multi method PPQ { $!PPQ }
    multi method FPS { $!FPS }
    multi method PPF { $!PPF }

        # Setters.
    multi method format ($format) { $!format = $format }
    multi method time-division ($td) { $!time-division = $td }
    multi method PPQ ($PPQ) { $!PPQ = $PPQ }
    multi method FPS ($FPS) { $!FPS = $FPS }
    multi method PPF ($PPF) { $!PPF = $PPF }

    has $!buf = Buf.new;

    my UInt16 $num-tracks = 0;

    method !write-header {
        my $b = Buf.new;
        $b.append: 'MThd'.ords;
        $b.append: write_4-bytes(6);
        $b.append: write_2-bytes($!format);
        $b.append: write_2-bytes($num-tracks);
        given $!time-division {
            when 'quarter' {
                $b.append: write_2-bytes($!PPQ);
            }
            when 'frame' {
                    # The first byte of the frame variant of
                    # time-division has the MSB set to 1 and the other
                    # seven bits set to the two's complement form
                    # of either one of these four negative FPS values:
                    # -24, -25, -29, -30
                    #
                    # We use a hack to achieve this. Instead of
                    # calculating the two's complement form, we
                    # subtract the positive FPS from 256 and this
                    # gives the correct answer for all FPS variants.
                    # FPS is floored to store 29.97 as 29.
                $b.append: 256 - $!FPS.floor;
                $b.append: $!PPF;
            }
        }
        return $b;
    }

    method add-track ($bytes) {
        $num-tracks++;
        $!buf.append: $bytes;
    }

    method render {
        my $b = Buf.new;
        $b.append: self!write-header;
        $b.append: $!buf;
        return $b;
    }
}

class Track is export(:shortnames) {
    subset Str-ASCII of Str where 32 ≤ *.ords.all ≤ 126;

    my %bytes =
        'note-off'       => 0x80,
        'note-on'        => 0x90,
        'meta-event'     => 0xFF,
        'copyright'      => 0x02,
        'name'           => 0x03,
        'instrument'     => 0x04,
        'marker'         => 0x06,
        'tempo'          => 0x51,
        'time-signature' => 0x58,
        'end-of-track'   => 0xF2,
    ;

    has Str-ASCII $.copyright = '';
    has Str-ASCII $.name = '';
    has Str-ASCII $.instrument = '';
    has UInt28 $.dt = 0;
    has UInt4  $.ch = 0;
    has UInt7  $.vol_note-off = 0;
    has UInt7  $.vol_note-on = 127;

        # Getters.
    multi method copyright { $!copyright }
    multi method name { $!name }
    multi method instrument { $!instrument }
    multi method dt { $!dt }
    multi method ch { $!ch }
    multi method vol_note-off { $!vol_note-off }
    multi method vol_note-on  { $!vol_note-on }

        # Setters.
    multi method copyright ($copyright) { $!copyright = $copyright }
    multi method name ($name) { $!name = $name }
    multi method instrument ($instrument) { $!instrument = $instrument }
    multi method dt ($dt) { $!dt = $dt }
    multi method ch ($ch) { $!ch = $ch }
    multi method vol_note-off ($vol) { $!vol_note-off = $vol }
    multi method vol_note-on  ($vol) { $!vol_note-on = $vol }

    has $!e = Buf.new; # Meta/Midi Events.

    method !VLQ-encode (UInt28 $n is copy) {
        my $byte = 0x7F +& $n;
        my $b = Buf.new($byte);
        $n +>= 7;
        while ($n) {
            $byte = 0x7F +& $n;
            $b.prepend: 0x80 +| $byte;
            $n +>= 7;
        }
        return $b;
    }

    method !render_header (UInt32 $num-bytes) {
        my $b = Buf.new;
        $b.append: 'MTrk'.ords;
        $b.append: write_4-bytes($num-bytes);
        return $b;
    }

    method !render_text ($meta-event, Str-ASCII $str) {
        return [] if ! $str.chars;
        my $b = Buf.new;
        $b.append: self!VLQ-encode(0);
        $b.append: %bytes{'meta-event'};
        $b.append: %bytes{$meta-event};
        $b.append: self!VLQ-encode($str.chars);
        $b.append: $str.ords;
        return $b;
    }

    method !render_end-of-track {
        my $b = Buf.new;
        $b.append: self!VLQ-encode(0);
        $b.append: %bytes{'meta-event'};
        $b.append: %bytes{'end-of-track'};
        $b.append: self!VLQ-encode(0);
        return $b;
    }

    method marker (Str-ASCII $marker) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'meta-event'};
        $!e.append: %bytes{'marker'};
        $!e.append: self!VLQ-encode($marker.chars);
        $!e.append: $marker.ords;
        $!dt = 0;
    }

    method tempo (
        UInt24 $tempo = 500000, # Microseconds per quarter note.
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'meta-event'};
        $!e.append: %bytes{'tempo'};
        $!e.append: self!VLQ-encode(3);
        $!e.append: write_4-bytes($tempo).splice(1);
        $!dt = 0;
    }

    method time (
        $time-signature = 4\4,
        UInt8 $PPMC = 24, # Pulses per metronome click.
        UInt8 $_32PQ = 8, # 32nds per quarter note.
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'meta-event'};
        $!e.append: %bytes{'time-signature'};
        $!e.append: self!VLQ-encode(4);
        $!e.append: $time-signature.MIDI-numerator;
        $!e.append: $time-signature.MIDI-denominator;
        $!e.append: $PPMC;
        $!e.append: $_32PQ;
        $!dt = 0;
    }

    method note-off (
        UInt7 $note,
        UInt7 $vol = $!vol_note-off,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'note-off'} + $!ch;
        $!e.append: $note;
        $!e.append: $vol;
        $!vol_note-off = $vol;
        $!dt = 0;
    }

    method note-on (
        UInt7 $note,
        UInt7 $vol = $!vol_note-on,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'note-on'} + $!ch;
        $!e.append: $note;
        $!e.append: $vol;
        $!vol_note-on = $vol;
        $!dt = 0;
    }

    method render {
        my $b = Buf.new;
        $b.append:  self!render_text('copyright', $!copyright);
        $b.append:  self!render_text('name', $!name);
        $b.append:  self!render_text('instrument', $!instrument);
        $b.append:  $!e;
        $b.append:  self!render_end-of-track;
        $b.prepend: self!render_header($b.bytes);
        return $b;
    }
}
