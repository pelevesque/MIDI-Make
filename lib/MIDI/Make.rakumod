subset UInt4  of UInt where * ≤ 15;
subset UInt7  of UInt where * ≤ 127;
subset UInt8  of UInt where * ≤ 255;
subset UInt15 of UInt where * ≤ 32767;
subset UInt16 of UInt where * ≤ 65535;
subset UInt24 of UInt where * ≤ 16777215;
subset UInt28 of UInt where * ≤ 268435455;
subset UInt32 of UInt where * ≤ 4294967295;

    # Operator: ♩PM
    # Transforms QNPM to μsPQN.
    # QNPM = Quarter notes per minute.
    # μsPQN = Microseconds per quarter note.
    # ➤ say 60♩PM; «1000000␤»
subset QNPM of Numeric where 0.22351741874 ≤ * ≤ 60000001;
sub postfix:<♩PM> (QNPM $QNPM) is export { (60000000 / $QNPM).floor }

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
    subset time-division where * ~~ 'quarter note' | 'frame';
    subset FPS where * ~~ 24 | 25 | 29.97 | 30;

    has format $.format is rw = 1;
    has time-division $.time-division is rw = 'quarter note';
    has FPS    $.FPS  is rw = 24; # Frames per second.
    has UInt8  $.PPF  is rw = 4;  # Pulses per frame.
    has UInt15 $.PPQN is rw = 48; # Pulses per quarter note.

    has $!buf = Buf.new;

    my UInt16 $num-tracks = 0;

    method !write-header {
        $!buf.append: 'MThd'.ords;
        $!buf.append: self.write_4-bytes(6);
        $!buf.append: self.write_2-bytes($!format);
        $!buf.append: self.write_2-bytes($num-tracks);
        given $!time-division {
            when 'quarter note' {
                $!buf.append: self.write_2-bytes($!PPQN);
            }
            when 'frame' {
                    # Floor FPS to store 29.97 as 29 for MIDI.
                $!buf.append: 256 - $!FPS.floor; # Two's complement form.
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

    has $!buf = Buf.new;

    method !VLQ-encode (UInt28 $n is copy) {
        my $byte = 0x7F +& $n;
        my $buf = Buf.new($byte);
        $n +>= 7;
        while ($n) {
            $byte = 0x7F +& $n;
            $buf.prepend: 0x80 +| $byte;
            $n +>= 7;
        }
        return $buf;
    }

    method !header (UInt32 $num-bytes) {
        my $buf = Buf.new;
        $buf.append: 'MTrk'.ords;
        $buf.append: self.write_4-bytes($num-bytes);
        $!buf.prepend: $buf;
    }

    method !end-of-track {
        $!buf.append: self!VLQ-encode(0);
        $!buf.append: %bytes{'meta-event'};
        $!buf.append: %bytes{'end-of-track'};
        $!buf.append: self!VLQ-encode(0);
    }

    method !name {
        my $buf = Buf.new;
        $buf.append: self!VLQ-encode(0);
        $buf.append: %bytes{'meta-event'};
        $buf.append: %bytes{'track-name'};
        $buf.append: self!VLQ-encode($!name.chars);
        $buf.append: $!name.ords;
        $!buf.prepend: $buf;
    }

    method time-signature (
        UInt28 :$dt = 0,
        :$time-signature = 4\4,
        UInt8 :$PPMC = 24, # Pulses per metronome click.
        UInt8 :$_32PQN = 8, # 32nds per quarter note.
    ) {
        $!buf.append: self!VLQ-encode($dt);
        $!buf.append: %bytes{'meta-event'};
        $!buf.append: %bytes{'time-signature'};
        $!buf.append: self!VLQ-encode(4);
        $!buf.append: $time-signature.MIDI-numerator;
        $!buf.append: $time-signature.MIDI-denominator;
        $!buf.append: $PPMC;
        $!buf.append: $_32PQN;
    }

    method tempo (
        UInt28 :$dt = 0,
        UInt24 :$tempo = 500000, # Microseconds per quarter note.
    ) {
        $!buf.append: self!VLQ-encode($dt);
        $!buf.append: %bytes{'meta-event'};
        $!buf.append: %bytes{'tempo'};
        $!buf.append: self!VLQ-encode(3);
        $!buf.append: self.write_4-bytes($tempo).splice(1);
    }

    method note-on (
        UInt28 :$dt = 0,
        UInt4  :$ch = 0,
        UInt7  :$note,
        UInt7  :$vol = 127,
    ) {
        $!buf.append: self!VLQ-encode($dt);
        $!buf.append: %bytes{'note-on'} + $ch;
        $!buf.append: $note;
        $!buf.append: $vol;
    }

    method note-off (
        UInt28 :$dt = 0,
        UInt4  :$ch = 0,
        UInt7  :$note,
        UInt7  :$vol = 0,
    ) {
        $!buf.append: self!VLQ-encode($dt);
        $!buf.append: %bytes{'note-off'} + $ch;
        $!buf.append: $note;
        $!buf.append: $vol;
    }

    method render {
        self!name if $!name.chars;
        self!end-of-track;
        self!header($!buf.bytes);
        return $!buf;
    }
}
