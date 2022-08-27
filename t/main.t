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
# Files

test(
    'Empty file',
    File.new,
    '4D 54 68 64 00 00 00 06 00 01 00 00 00 30',
);

test(
    'Empty file, format 2',
    File.new(:format(2)),
    '4D 54 68 64 00 00 00 06 00 02 00 00 00 30',
);

test(
    'Time division',
    File.new(:time-division('frame')),
    '4D 54 68 64 00 00 00 06 00 01 00 00 E8 04',
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
