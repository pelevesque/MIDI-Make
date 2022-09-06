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
    'Trackless File',
    File.new,
    '4D 54 68 64 00 00 00 06 00 01 00 00 00 30',
);

test(
    'Trackless File: format => 0',
    File.new(:format(0)),
    '4D 54 68 64 00 00 00 06 00 00 00 00 00 30',
);

test(
    'Trackless File: PPQ => 300',
    File.new(:PPQ(300)),
    '4D 54 68 64 00 00 00 06 00 01 00 00 01 2C',
);

test(
    'Trackless File: time-division => "frame"',
    File.new(:time-division('frame')),
    '4D 54 68 64 00 00 00 06 00 01 00 00 E8 04',
);

test(
    'Trackless File: FPS => 29.97',
    File.new(:time-division('frame'), :FPS(29.97)),
    '4D 54 68 64 00 00 00 06 00 01 00 00 E3 04',
);

test(
    'Trackless File: PPF => 8',
    File.new(:time-division('frame'), :PPF(24)),
    '4D 54 68 64 00 00 00 06 00 01 00 00 E8 18',
);

test(
    'Trackless File: Set params after instantiation 1',
    do {
        my $f = File.new;
        $f.format: 2;
        $f.PPQ: 425;
        $f;
    },
    '4D 54 68 64 00 00 00 06 00 02 00 00 01 A9',
);

test(
    'Trackless File: Set params after instantiation 2',
    do {
        my $f = File.new;
        $f.format: 1;
        $f.time-division: 'frame';
        $f.FPS: 30;
        $f.PPF: 48;
        $f;
    },
    '4D 54 68 64 00 00 00 06 00 01 00 00 E2 30',
);

# --------------------------------------------------------------------
# Tracks

test(
    'Empty Track',
    Track.new,
    '4D 54 72 6B 00 00 00 04 00 FF F2 00',
);

# --------------------------------------------------------------------
# Files + Tracks

test(
    'complic',
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
    '4D 54 68 64 00 00 00 06 00 01 00 01 00 30 4D 54 72 6B 00 00 00 1F
    00 FF 03 05 70 69 61 6E 6F 00 90 3C 7F 81 00 80 3C 00 00 90 48 7F
    81 00 80 48 00 00 FF F2 00',
);
