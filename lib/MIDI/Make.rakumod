unit module MIDI::Make;

subset UInt4  of UInt where * ≤ 15;
subset UInt7  of UInt where * ≤ 127;
subset UInt8  of UInt where * ≤ 255;
subset UInt14 of UInt where * ≤ 16383;
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
sub prefix:<♩> (QPM $QPM) is export { (60000000 / $QPM).floor }

    # Operator: \
    # Helps to write human-like time signatures.
    # ➤ say (2\8).MIDI-nominator; «2␤»
    # ➤ say (2\8).MIDI-denominator; «3␤»
my constant @pow2 = ^256 »**» 2; # 2⁰ → 2²⁵⁵
subset Pow2 of UInt where * ~~ any @pow2;
sub infix:<\\> (UInt8 $numerator, Pow2 $denominator) is export {
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

class Song is export {
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

class Track is export {
    subset ASCII of Str where 32 ≤ *.ords.all ≤ 126;

    my %bytes =
        'note-off'       => 0x80,
        'note-on'        => 0x90,
        'aftertouch'     => 0xA0,
        'controller'     => 0xB0,
        'program-change' => 0xC0,
        'pitch-bend'     => 0xE0,
        'meta-event'     => 0xFF,
        'text'           => 0x01,
        'copyright'      => 0x02,
        'name'           => 0x03,
        'instrument'     => 0x04,
        'lyric'          => 0x05,
        'marker'         => 0x06,
        'cue'            => 0x07,
        'program'        => 0x08,
        'port'           => 0x09,
        'tempo'          => 0x51,
        'time-signature' => 0x58,
        'end-of-track'   => 0xF2,
    ;

    has ASCII  $.copyright = '';
    has ASCII  $.name = '';
    has ASCII  $.instrument = '';
    has UInt28 $.dt = 0;
    has UInt4  $.ch = 0;
    has UInt7  $.vel_note-off = 0;
    has UInt7  $.vel_note-on = 127;

        # Getters.
    multi method copyright { $!copyright }
    multi method name { $!name }
    multi method instrument { $!instrument }
    multi method dt { $!dt }
    multi method ch { $!ch }
    multi method vel_note-off { $!vel_note-off }
    multi method vel_note-on  { $!vel_note-on }

        # Setters.
    multi method copyright ($copyright) { $!copyright = $copyright }
    multi method name ($name) { $!name = $name }
    multi method instrument ($instrument) { $!instrument = $instrument }
    multi method dt ($dt) { $!dt = $dt }
    multi method ch ($ch) { $!ch = $ch }
    multi method vel_note-off ($vel) { $!vel_note-off = $vel }
    multi method vel_note-on  ($vel) { $!vel_note-on = $vel }

    has $!e = Buf.new; # Meta/Midi Events.

    method !MSB (UInt14 $n) { $n +> 7 }
    method !LSB (UInt14 $n) { 0x7F +& $n }

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
        $b.append: write_4-bytes($num-bytes);
        return $b;
    }

        # Text that must be placed at a track's beginning.
        #
        # Note: Unlike the other methods, dt is not automatically
        # reset to 0 at the end of this method. This is so it remains
        # unchanged for !end-of-track and future renders.
    method !lead-text ($meta-event, ASCII $s) {
        self!text-buffer($meta-event, $s, 0);
    }

        # Text that may be placed anywhere.
    method !text ($meta-event, ASCII $s) {
        my $b = self!text-buffer($meta-event, $s, $!dt);
        $!dt = 0;
        return $b;
    }

    method !text-buffer ($meta-event, ASCII $s, UInt28 $dt) {
        return [] if ! $s.chars;
        my $b = Buf.new;
        $b.append: self!VLQ-encode($dt);
        $b.append: %bytes{'meta-event'};
        $b.append: %bytes{$meta-event};
        $b.append: self!VLQ-encode($s.chars);
        $b.append: $s.ords;
        return $b;
    }

    method !copyright  { self!lead-text('copyright',  $!copyright ) }
    method !name       { self!lead-text('name',       $!name      ) }
    method !instrument { self!lead-text('instrument', $!instrument) }

    method !end-of-track {
        my $b = Buf.new;
        $b.append: self!VLQ-encode($!dt);
        $b.append: %bytes{'meta-event'};
        $b.append: %bytes{'end-of-track'};
        $b.append: 0;
        return $b;
    }

    method text    (ASCII $s) { $!e.append: self!text('text',    $s) }
    method lyric   (ASCII $s) { $!e.append: self!text('lyric',   $s) }
    method marker  (ASCII $s) { $!e.append: self!text('marker',  $s) }
    method cue     (ASCII $s) { $!e.append: self!text('cue',     $s) }
    method program (ASCII $s) { $!e.append: self!text('program', $s) }
    method port    (ASCII $s) { $!e.append: self!text('port',    $s) }

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

    method time-signature (
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
        UInt7 $vel = $!vel_note-off,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'note-off'} + $!ch;
        $!e.append: $note;
        $!e.append: $vel;
        $!vel_note-off = $vel;
        $!dt = 0;
    }

    method note-on (
        UInt7 $note,
        UInt7 $vel = $!vel_note-on,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'note-on'} + $!ch;
        $!e.append: $note;
        $!e.append: $vel;
        $!vel_note-on = $vel;
        $!dt = 0;
    }

    method aftertouch (
        UInt7 $note,
        UInt7 $amount,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'aftertouch'} + $!ch;
        $!e.append: $note;
        $!e.append: $amount;
        $!dt = 0;
    }

    method controller (
        UInt7 $controller,
        UInt7 $val,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'controller'} + $!ch;
        $!e.append: $controller;
        $!e.append: $val;
        $!dt = 0;
    }

    method bank-select_MSB     (UInt7 $v) { self.controller(  0, $v) }
    method modulation_MSB      (UInt7 $v) { self.controller(  1, $v) }
    method breath_MSB          (UInt7 $v) { self.controller(  2, $v) }
        # 3 is undefined.
    method foot-pedal_MSB      (UInt7 $v) { self.controller(  4, $v) }
    method portamento-time_MSB (UInt7 $v) { self.controller(  5, $v) }
    method data-entry_MSB      (UInt7 $v) { self.controller(  6, $v) }
    method channel-volume_MSB  (UInt7 $v) { self.controller(  7, $v) }
    method balance_MSB         (UInt7 $v) { self.controller(  8, $v) }
        # 9 is undefined.
    method pan_MSB             (UInt7 $v) { self.controller( 10, $v) }
    method expression_MSB      (UInt7 $v) { self.controller( 11, $v) }
    method fx-control_1_MSB    (UInt7 $v) { self.controller( 12, $v) }
    method fx-control_2_MSB    (UInt7 $v) { self.controller( 13, $v) }
        # 14-15 are undefined.
    method gen-control_1_MSB   (UInt7 $v) { self.controller( 16, $v) }
    method gen-control_2_MSB   (UInt7 $v) { self.controller( 17, $v) }
    method gen-control_3_MSB   (UInt7 $v) { self.controller( 18, $v) }
    method gen-control_4_MSB   (UInt7 $v) { self.controller( 19, $v) }
        # 20-31 are undefined.
    method bank-select_LSB     (UInt7 $v) { self.controller( 32, $v) }
    method modulation_LSB      (UInt7 $v) { self.controller( 33, $v) }
    method breath_LSB          (UInt7 $v) { self.controller( 34, $v) }
        # 35 is undefined.
    method foot-pedal_LSB      (UInt7 $v) { self.controller( 36, $v) }
    method portamento-time_LSB (UInt7 $v) { self.controller( 37, $v) }
    method data-entry_LSB      (UInt7 $v) { self.controller( 38, $v) }
    method channel-volume_LSB  (UInt7 $v) { self.controller( 39, $v) }
    method balance_LSB         (UInt7 $v) { self.controller( 40, $v) }
        # 41 is undefined.
    method pan_LSB             (UInt7 $v) { self.controller( 42, $v) }
    method expression_LSB      (UInt7 $v) { self.controller( 43, $v) }
    method fx-control_1_LSB    (UInt7 $v) { self.controller( 44, $v) }
    method fx-control_2_LSB    (UInt7 $v) { self.controller( 45, $v) }
        # 46-47 are undefined.
    method gen-control_1_LSB   (UInt7 $v) { self.controller( 48, $v) }
    method gen-control_2_LSB   (UInt7 $v) { self.controller( 49, $v) }
    method gen-control_3_LSB   (UInt7 $v) { self.controller( 50, $v) }
    method gen-control_4_LSB   (UInt7 $v) { self.controller( 51, $v) }
        # 52-63 are undefined.
    method hold_1-pedal        (UInt7 $v) { self.controller( 64, $v) }
    method portamento          (UInt7 $v) { self.controller( 65, $v) }
    method sostenuto           (UInt7 $v) { self.controller( 66, $v) }
    method soft-pedal          (UInt7 $v) { self.controller( 67, $v) }
    method legato-footswitch   (UInt7 $v) { self.controller( 68, $v) }
    method hold_2-pedal        (UInt7 $v) { self.controller( 69, $v) }
    method sound-control_1     (UInt7 $v) { self.controller( 70, $v) }
    method sound-control_2     (UInt7 $v) { self.controller( 71, $v) }
    method sound-control_3     (UInt7 $v) { self.controller( 72, $v) }
    method sound-control_4     (UInt7 $v) { self.controller( 73, $v) }
    method sound-control_5     (UInt7 $v) { self.controller( 74, $v) }
    method sound-control_6     (UInt7 $v) { self.controller( 75, $v) }
    method sound-control_7     (UInt7 $v) { self.controller( 76, $v) }
    method sound-control_8     (UInt7 $v) { self.controller( 77, $v) }
    method sound-control_9     (UInt7 $v) { self.controller( 78, $v) }
    method sound-control_10    (UInt7 $v) { self.controller( 79, $v) }
    method gen-control_5       (UInt7 $v) { self.controller( 80, $v) }
    method gen-control_6       (UInt7 $v) { self.controller( 81, $v) }
    method gen-control_7       (UInt7 $v) { self.controller( 82, $v) }
    method gen-control_8       (UInt7 $v) { self.controller( 83, $v) }
    method portamento-control  (UInt7 $v) { self.controller( 84, $v) }
        # 85-87 are undefined.
    method hi-res-vel-prefix   (UInt7 $v) { self.controller( 88, $v) }
        # 89-90 are undefined.
    method fx_1-depth          (UInt7 $v) { self.controller( 91, $v) }
    method fx_2-depth          (UInt7 $v) { self.controller( 92, $v) }
    method fx_3-depth          (UInt7 $v) { self.controller( 93, $v) }
    method fx_4-depth          (UInt7 $v) { self.controller( 94, $v) }
    method fx_5-depth          (UInt7 $v) { self.controller( 95, $v) }
    method data-increment      (UInt7 $v) { self.controller( 96, $v) }
    method data-decrement      (UInt7 $v) { self.controller( 97, $v) }
    method NRPN_LSB            (UInt7 $v) { self.controller( 98, $v) }
    method NRPN_MSB            (UInt7 $v) { self.controller( 99, $v) }
    method RPN_LSB             (UInt7 $v) { self.controller(100, $v) }
    method RPN_MSB             (UInt7 $v) { self.controller(101, $v) }
        # 102-119 are undefined.
    method all-sounds-off      (UInt7 $v) { self.controller(120, $v) }
    method reset-controllers   (UInt7 $v) { self.controller(121, $v) }
    method local-switch        (UInt7 $v) { self.controller(122, $v) }
    method all-notes-off       (UInt7 $v) { self.controller(123, $v) }
    method omni-mode-off       (UInt7 $v) { self.controller(124, $v) }
    method omni-mode-on        (UInt7 $v) { self.controller(125, $v) }
    method mono-mode           (UInt7 $v) { self.controller(126, $v) }
    method poly-mode           (UInt7 $v) { self.controller(127, $v) }

    method bank-select (UInt14 $v) {
        self.bank-select_MSB(self!MSB($v));
        self.bank-select_LSB(self!LSB($v));
    }
    method modulation (UInt14 $v) {
        self.modulation_MSB(self!MSB($v));
        self.modulation_LSB(self!LSB($v));
    }
    method breath (UInt14 $v) {
        self.breath_MSB(self!MSB($v));
        self.breath_LSB(self!LSB($v));
    }
    method foot-pedal (UInt14 $v) {
        self.foot-pedal_MSB(self!MSB($v));
        self.foot-pedal_LSB(self!LSB($v));
    }
    method portamento-time (UInt14 $v) {
        self.portamento-time_MSB(self!MSB($v));
        self.portamento-time_LSB(self!LSB($v));
    }
    method data-entry (UInt14 $v) {
        self.data-entry_MSB(self!MSB($v));
        self.data-entry_LSB(self!LSB($v));
    }
    method channel-volume (UInt14 $v) {
        self.channel-volume_MSB(self!MSB($v));
        self.channel-volume_LSB(self!LSB($v));
    }
    method balance (UInt14 $v) {
        self.balance_MSB(self!MSB($v));
        self.balance_LSB(self!LSB($v));
    }
    method pan (UInt14 $v) {
        self.pan_MSB(self!MSB($v));
        self.pan_LSB(self!LSB($v));
    }
    method expression (UInt14 $v) {
        self.expression_MSB(self!MSB($v));
        self.expression_LSB(self!LSB($v));
    }
    method fx-control_1 (UInt14 $v) {
        self.fx-control_1_MSB(self!MSB($v));
        self.fx-control_1_LSB(self!LSB($v));
    }
    method fx-control_2 (UInt14 $v) {
        self.fx-control_2_MSB(self!MSB($v));
        self.fx-control_2_LSB(self!LSB($v));
    }
    method gen-control_1 (UInt14 $v) {
        self.gen-control_1_MSB(self!MSB($v));
        self.gen-control_1_LSB(self!LSB($v));
    }
    method gen-control_2 (UInt14 $v) {
        self.gen-control_2_MSB(self!MSB($v));
        self.gen-control_2_LSB(self!LSB($v));
    }
    method gen-control_3 (UInt14 $v) {
        self.gen-control_3_MSB(self!MSB($v));
        self.gen-control_3_LSB(self!LSB($v));
    }
    method gen-control_4 (UInt14 $v) {
        self.gen-control_4_MSB(self!MSB($v));
        self.gen-control_4_LSB(self!LSB($v));
    }

    method program-change (
        UInt7 $program-number,
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'program-change'} + $!ch;
        $!e.append: $program-number;
        $!dt = 0;
    }

    method pitch-bend (
        UInt14 $pitch-bend = 8192, # Defaults to no pitch-bend.
    ) {
        $!e.append: self!VLQ-encode($!dt);
        $!e.append: %bytes{'pitch-bend'} + $!ch;
        $!e.append: self!LSB($pitch-bend);
        $!e.append: self!MSB($pitch-bend);
        $!dt = 0;
    }

    method render {
        my $b = Buf.new;
        $b.append:  self!copyright;
        $b.append:  self!name;
        $b.append:  self!instrument;
        $b.append:  $!e;
        $b.append:  self!end-of-track;
        $b.prepend: self!header($b.bytes);
        return $b;
    }
}
