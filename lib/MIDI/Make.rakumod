subset UInt4  of UInt where * ≤ 15;
subset UInt7  of UInt where * ≤ 127;
subset UInt8  of UInt where * ≤ 255;
subset UInt15 of UInt where * ≤ 32767;
subset UInt16 of UInt where * ≤ 65535;
subset UInt24 of UInt where * ≤ 16777215;
subset UInt28 of UInt where * ≤ 268435455;
subset UInt32 of UInt where * ≤ 4294967295;

    # Operator: ♩PM | QPM
    # Transforms QPM to μsPQ.
    # QPM = Quarter notes per minute.
    # μsPQ = Microseconds per quarter note.
    # ➤ say 60♩PM; «1000000␤»
subset QPM of Numeric where 0.22351741874 ≤ * ≤ 60000001;
sub postfix:<♩PM> (QPM $QPM) is export { (60000000 / $QPM).floor }
sub postfix:<QPM> (QPM $QPM) is export { (60000000 / $QPM).floor }

    # Operator: \
    # Helps to write human-like time signatures.
    # ➤ say (2\8).MIDI-nominator; «2␤»
    #   say (2\8).MIDI-denominator; «3␤»
sub infix:<\\> (UInt8 $numerator, UInt $denominator) is export {
    class Time-Signature {
        has UInt8 $.numerator;
        has UInt  $.denominator;
        method MIDI-numerator { $!numerator }
        method MIDI-denominator { Int($!denominator.log(2)) }
    }
    Time-Signature.new: :$numerator, :$denominator;
}

class MIDI-Base {
    constant $ENDIANNESS = BigEndian;

    method write_2-bytes (UInt16 $n) {
        Buf.write-uint16(0, $n, $ENDIANNESS);
    }

    method write_4-bytes (UInt32 $n) {
        Buf.write-uint32(0, $n, $ENDIANNESS);
    }
}

class MIDI-Make is MIDI-Base {
    subset format where * ~~ 0 | 1 | 2;
    subset time-division where * ~~ 'quarter' | 'frame';
    subset FPS where * ~~ 24 | 25 | 29.97 | 30;

    has format $.format is rw = 1;
    has time-division $.time-division is rw = 'quarter';
    has FPS    $.FPS is rw = 24; # Frames per second.
    has UInt8  $.PPF is rw = 4;  # Pulses per frame.
    has UInt15 $.PPQ is rw = 48; # Pulses per quarter note.

    has $!buf = Buf.new;

    my UInt16 $num-tracks = 0;

    method !write-header {
        $!buf.append: 'MThd'.ords;
        $!buf.append: self.write_4-bytes(6);
        $!buf.append: self.write_2-bytes($!format);
        $!buf.append: self.write_2-bytes($num-tracks);
        given $!time-division {
            when 'quarter' {
                $!buf.append: self.write_2-bytes($!PPQ);
            }
            when 'frame' {
                    # The first byte of the frame variant of
                    # time-division has the MSB set to 1 and the other
                    # seven bits set to the two's complement form
                    # of either one of the four negative FPS values:
                    # -24, -25, -29, -30
                    #
                    # We use a hack to achieve this. Instead of
                    # calculating the two's complement form, we
                    # substract the positive FPS from 256 and this
                    # gives the correct answer for all FPS variants.
                    # FPS is floored to store 29.97 as 29.
                $!buf.append: 256 - $!FPS.floor;
                $!buf.append: $!PPF;
            }
        }
    }

    method add-track ($bytes) {
        $num-tracks++;
        $!buf.append: $bytes;
    }

    method render {
        self!write-header;
        return $!buf;
    }
}

class Track is MIDI-Base {
    subset Str-ASCII of Str where 32 ≤ *.ords.all ≤ 126;

    my %bytes =
        'note-on'        => 0x90,
        'note-off'       => 0x80,
        'meta-event'     => 0xFF,
        'track-name'     => 0x03,
        'tempo'          => 0x51,
        'time-signature' => 0x58,
        'end-of-track'   => 0xF2,
    ;

    has Str-ASCII $.name is rw;

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

    method !header (UInt32 $num-bytes) {
        my $b = Buf.new;
        $b.append: 'MTrk'.ords;
        $b.append: self.write_4-bytes($num-bytes);
        return $b;
    }

    method !end-of-track {
        my $b = Buf.new;
        $b.append: self!VLQ-encode(0);
        $b.append: %bytes{'meta-event'};
        $b.append: %bytes{'end-of-track'};
        $b.append: self!VLQ-encode(0);
        return $b;
    }

    method !name {
        my $b = Buf.new;
        $b.append: self!VLQ-encode(0);
        $b.append: %bytes{'meta-event'};
        $b.append: %bytes{'track-name'};
        $b.append: self!VLQ-encode($!name.chars);
        $b.append: $!name.ords;
        return $b;
    }

    method time-signature (
        UInt28 :$dt = 0,
        :$time-signature = 4\4,
        UInt8 :$PPMC = 24, # Pulses per metronome click.
        UInt8 :$_32PQ = 8, # 32nds per quarter note.
    ) {
        $!e.append: self!VLQ-encode($dt);
        $!e.append: %bytes{'meta-event'};
        $!e.append: %bytes{'time-signature'};
        $!e.append: self!VLQ-encode(4);
        $!e.append: $time-signature.MIDI-numerator;
        $!e.append: $time-signature.MIDI-denominator;
        $!e.append: $PPMC;
        $!e.append: $_32PQ;
    }

    method tempo (
        UInt28 :$dt = 0,
        UInt24 :$tempo = 500000, # Microseconds per quarter note.
    ) {
        $!e.append: self!VLQ-encode($dt);
        $!e.append: %bytes{'meta-event'};
        $!e.append: %bytes{'tempo'};
        $!e.append: self!VLQ-encode(3);
        $!e.append: self.write_4-bytes($tempo).splice(1);
    }

    method note-on (
        UInt28 :$dt = 0,
        UInt4  :$ch = 0,
        UInt7  :$note,
        UInt7  :$vol = 127,
    ) {
        $!e.append: self!VLQ-encode($dt);
        $!e.append: %bytes{'note-on'} + $ch;
        $!e.append: $note;
        $!e.append: $vol;
    }

    method note-off (
        UInt28 :$dt = 0,
        UInt4  :$ch = 0,
        UInt7  :$note,
        UInt7  :$vol = 0,
    ) {
        $!e.append: self!VLQ-encode($dt);
        $!e.append: %bytes{'note-off'} + $ch;
        $!e.append: $note;
        $!e.append: $vol;
    }

    method render {
        my $b = Buf.new;
        $b.append:  self!name if $!name.chars;
        $b.append:  $!e;
        $b.append:  self!end-of-track;
        $b.prepend: self!header($b.bytes);
        return $b;
    }
}
