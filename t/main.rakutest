use Test;
use MIDI::Make;

sub test ($title, $renderable, $exp-bytes) {
    is(
        $renderable.render,
        Buf.new($exp-bytes.words.map({"0x$_"})>>.Int),
        $title,
    );
}

# --------------------------------------------------------------------
# Trackless Files

test(
    'Trackless File Instantiation',
    File.new,
    '4D 54 68 64 00 00 00 06
     00 01 00 00 00 30',
);

test(
    'Trackless File Instantiation: format => 0',
    File.new(:format(0)),
    '4D 54 68 64 00 00 00 06
     00 00 00 00 00 30',
);

test(
    'Trackless File Instantiation: time-division => "frame"',
    File.new(:time-division('frame')),
    '4D 54 68 64 00 00 00 06
     00 01 00 00 E8 04',
);

test(
    'Trackless File Instantiation: PPQ => 300',
    File.new(:PPQ(300)),
    '4D 54 68 64 00 00 00 06
     00 01 00 00 01 2C',
);

test(
    'Trackless File Instantiation: FPS => 29.97',
    File.new(:time-division('frame'), :FPS(29.97)),
    '4D 54 68 64 00 00 00 06
     00 01 00 00 E3 04',
);

test(
    'Trackless File Instantiation: PPF => 8',
    File.new(:time-division('frame'), :PPF(24)),
    '4D 54 68 64 00 00 00 06
     00 01 00 00 E8 18',
);

test(
    'Trackless File: Set params after instantiation A',
    do {
        my $f = File.new;
        $f.format: 2;
        $f.PPQ: 425;
        $f;
    },
    '4D 54 68 64 00 00 00 06
     00 02 00 00 01 A9',
);

test(
    'Trackless File: Set params after instantiation B',
    do {
        my $f = File.new;
        $f.format: 1;
        $f.time-division: 'frame';
        $f.FPS: 30;
        $f.PPF: 48;
        $f;
    },
    '4D 54 68 64 00 00 00 06
     00 01 00 00 E2 30',
);

# --------------------------------------------------------------------
# Tracks

test(
    'Track Instantiation',
    Track.new,
    '4D 54 72 6B 00 00 00 04
     00 FF F2 00',
);

test(
    'Track Instantiation: name => "piano"',
    Track.new(:name('piano')),
    '4D 54 72 6B 00 00 00 0D
     00 FF 03 05 70 69 61 6E 6F
     00 FF F2 00',
);

test(
    'Track Instantiation: dt => 100',
    do {
        my $t = Track.new(:dt(100));
        $t.note-on: 60;
        $t;
    },
    '4D 54 72 6B 00 00 00 08
     64 90 3C 7F
     00 FF F2 00',
);

test(
    'Track Instantiation: ch => 1',
    do {
        my $t = Track.new(:ch(1));
        $t.note-on: 60;
        $t;
    },
    '4D 54 72 6B 00 00 00 08
     00 91 3C 7F
     00 FF F2 00',
);

test(
    'Track Instantiation: vol_note-off => 10',
    do {
        my $t = Track.new(:vol_note-off(10));
        $t.note-off: 60;
        $t;
    },
    '4D 54 72 6B 00 00 00 08
     00 80 3C 0A
     00 FF F2 00',
);

test(
    'Track Instantiation: vol_note-on => 100',
    do {
        my $t = Track.new(:vol_note-on(100));
        $t.note-on: 60;
        $t;
    },
    '4D 54 72 6B 00 00 00 08
     00 90 3C 64
     00 FF F2 00',
);

test(
    'Track: Change params after instantiation',
    do {
        my $t = Track.new;
        $t.dt: 100;
        $t.ch: 1;
        $t.vol_note-off: 10;
        $t.vol_note-on: 100;
        $t.note-on: 60;
        $t.note-off: 60;
        $t;
    },
    '4D 54 72 6B 00 00 00 0C
     64 91 3C 64
     00 81 3C 0A
     00 FF F2 00',
);

test(
    'Track: tempo with default params',
    do {
        my $t = Track.new;
	    $t.tempo;
	    $t;
    },
    '4D 54 72 6B 00 00 00 0B
     00 FF 51 03 07 A1 20
     00 FF F2 00'
);

test(
    'Track: tempo with custom params',
    do {
        my $t = Track.new;
	    $t.dt: 100;
	    $t.tempo: 10250;
	    $t;
    },
    '4D 54 72 6B 00 00 00 0B
     64 FF 51 03 00 28 0A
     00 FF F2 00'
);

test(
    'Track: time with default params',
    do {
        my $t = Track.new;
	    $t.time;
	    $t;
    },
    '4D 54 72 6B 00 00 00 0C
     00 FF 58 04 04 02 18 08
     00 FF F2 00'
);

test(
    'Track: time with custom params',
    do {
        my $t = Track.new;
	    $t.dt: 100;
	    $t.time: 2\8, 32, 4;
	    $t;
    },
    '4D 54 72 6B 00 00 00 0C
     64 FF 58 04 02 03 20 04
     00 FF F2 00'
);

test(
    'Track: note-on and note-off',
    do {
        my $t = Track.new;
        $t.note-on: 60;
        $t.note-off: 60;
        $t.note-on: 127, 100;
        $t.note-off: 127, 10;
        $t.note-on: 60;
        $t.note-off: 60;
        $t;
    },
    '4D 54 72 6B 00 00 00 1C
     00 90 3C 7F
     00 80 3C 00
     00 90 7F 64
     00 80 7F 0A
     00 90 3C 64
     00 80 3C 0A
     00 FF F2 00',
);

# --------------------------------------------------------------------
# Files + Tracks

test(
    'Complex example',
    do {
        my $t = Track.new;
        $t.name:     "piano";
        $t.note-on:  60;
        $t.dt:       128;
        $t.note-off: 60;
        $t.note-on:  72;
        $t.dt:       128;
        $t.note-off: 72;

        my $f = File.new;
        $f.add-track($t.render);
        $f;
    },
    '4D 54 68 64 00 00 00 06
     00 01 00 01 00 30
     4D 54 72 6B 00 00 00 1F
     00 FF 03 05 70 69 61 6E 6F
     00 90 3C 7F 81
     00 80 3C 00
     00 90 48 7F 81
     00 80 48 00
     00 FF F2 00',
);
