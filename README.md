[![Actions Status](https://github.com/pelevesque/MIDI-Make/actions/workflows/test.yml/badge.svg)](https://github.com/pelevesque/MIDI-Make/actions)

# MIDI::Make

A [Raku](https://www.raku.org) module to make MIDI files.

## Synopsis

```raku
use MIDI::Make;

my $t = Track.new;
$t.copyright:      'c 2022 anonymous';
$t.name:           'melody';
$t.instrument:     'piano';
$t.controller:     8, 100;
$t.pan:            20;
$t.program:        'electric piano';
$t.port:           'MIDI Out 1';
$t.ch:             1;
$t.pitch-bend:     0;
$t.marker:                 'section I';
$t.text:           'Lorem ipsum dolor sit amet.';
$t.tempo:          ♩80;
$t.time-signature: 3\2;
$t.aftertouch:     60, 100;
$t.note-on:        60;
$t.lyric:          'one';
$t.dt:                 128;
$t.note-off:       60;
$t.cue:            'door slam';
$t.vol_note-on:    80;
$t.vol_note-off:   10;
$t.note-on:        72;
$t.lyric:          'two';
$t.dt:                 128;
$t.note-off:       72;

my $s = Song.new(:PPQ(96));
$s.add-track($t.render);

    # Print the MIDI contents.
say $s.render;

    # Save the MIDI contents to file.
spurt 'file.mid', $s.render;
```

## Versioning

MIDI::Make uses [Semantic Versioning](https://semver.org).

## Installation

You can install MIDI::Make using [Zef](https://github.com/ugexe/zef).

```
➤ zef install MIDI::Make
```

## Import

```raku
use MIDI::Make;
```

## Usage

MIDI::Make works by creating the Song class and then populating it
with zero or more tracks created using the Track class. The resulting
MIDI information can be outputed using the Song class's render method.

## The Song class

The Song class is used to store and modify MIDI information in order
to create a MIDI file. It has some optional parameters, the add-track
method to add tracks, and the render method to output the MIDI
information created up to that point.

```raku
    # Instantiating without parameters.
my $f = Song.new;
```

### Parameters

Parameters can be set on instantiation, or anytime afterwards.

#### format

The format parameter specifies the type of MIDI file format to use.

It can have three values: 0, 1, or 2. The default is 1.

-  0 - All data is merged on a single track.
-  1 - Tracks are separated, and played together.
-  2 - Tracks are separated, and played one after the other.

```raku
    # Set on instantiation.
my $f = Song.new(:format(0));
```

```raku
    # Set after instantiation.
my $f = Song.new;
$f.format: 0;
```

#### time-division

The time-division parameter defines how MIDI time will be divided.

It can have two values: quarter for quarter notes, and frame. The
default is quarter.

```raku
    # Set on instantiation.
my $f = Song.new(:time-division('frame'));
```

```raku
    # Set after instantiation.
my $f = Song.new;
$f.time-division: 'frame';
```

#### PPQ (pulses per quarter note)

The PPQ parameter sets the pulses per quarter note of the
time-division parameter when the latter is set to quarter. If
time-division is set to frame, PPQ is ignored.

The PPQ value is from 0 to 32767. The default is 48.

```raku
    # Set on instantiation.
my $f = Song.new(:PPQ(96));
```

```raku
    # Set after instantiation.
my $f = Song.new;
$f.PPQ: 96;
```

#### FPS (frames per second)

The FPS parameter sets the frames per second of the time-division
parameter when the latter is set to frame. If time-division is set to
quarter, FPS is ignored.

FPS can have four values: 24, 25, 29.97, or 30. The default is 24.

```raku
    # Set on instantiation.
my $f = Song.new(:time-division('frame'), :FPS(30));
```

```raku
    # Set after instantiation.
my $f = Song.new;
$f.time-division: 'frame';
$f.FPS: 30;
```

#### PPF (pulses per frame)

The PPF parameter sets the pulses per frame of the time-division
parameter when the latter is set to frame. If time-division is set to
quarter, PPF is ignored.

The PPF value is from 0 to 255. The default is 4.

```raku
    # Set on instantiation.
my $f = Song.new(:time-division('frame'), :PPF(8));
```

```raku
    # Set after instantiation.
my $f = Song.new;
$f.time-division: 'frame';
$f.PPF: 8;
```

### Methods

#### add-track

The add-track method accepts a rendered track, and adds it to the Song
class.

```raku
    # Create a track.
my $t = Track.new;
$t.note-on:  60;
$t.dt:           100;
$t.note-off: 60;

    # Add it to the Song class.
my $f = Song.new;
$f.add-track($t.render);
```

#### render

The render method renders the MIDI file information gathered up to
that point.

```raku
my $f = Song.new;
say $f.render;
```

## Operators

MIDI::Make creates two operators that serve as helpers for the Track
class described below.

### ♩

The quarter notes per minute operator transforms quarter notes per
minute to microseconds per quarter note.

This permits specifying tempo in a musical human-readable way.

```raku
    # 60 QPM using microseconds per quarter note.
$t.tempo: 1000000;

    # 60 QPM using the MIDI::Make operator.
$t.tempo: ♩60;
```

### \

The time-signature operator is used to specify a time-signature for
the Track class's time-signature method.

```raku
$t.time-signature: 3\8;
```

## The Track class

The Track class is used to create a MIDI track which can then be added
to the Song class.

```raku
    # Instantiating without parameters.
my $t = Track.new;
```

### Parameters

Parameters can be set on instantiation, or anytime afterwards.

#### copyright

The copyright parameter lets you set the MIDI file's copyright using
ASCII characters.

Note: This copyright is usually placed at time 0 of the first track
in the sequence.

```raku
    # Set on instantiation.
my $t = Track.new(:copyright('c 2022 anonymous'));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.copyright: 'c 2022 anonymous';
```

#### name

The name parameter lets you set the track's name using
ASCII characters.

```raku
    # Set on instantiation.
my $t = Track.new(:name('melody'));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.name: 'melody';
```

#### instrument

The instrument parameter lets you set the track's instrument using
ASCII characters.

```raku
    # Set on instantiation.
my $t = Track.new(:instrument('piano'));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.instrument: 'piano';
```

#### dt

Delta time (dt) sets the time in MIDI pulses between MIDI events.

The dt value is from O to 268435455. The default is 0.

Note: Although it's possible to instantiate dt to a value other than
0, usually you will start a MIDI file with a MIDI event, and not a
period of time.

```raku
    # Set on instantiation.
my $t = Track.new(:dt(100));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.dt: 100;
```

dt is automatically set to 0 after each of the MIDI events implemented
in the Track class. This is done so that you can enter many MIDI
events consecutively before setting a new dt.

```raku
my $t = Track.new;
$t.note-on:  60;
$t.dt:          100; # Wait 100 MIDI pulses before subsequent events.
$t.note-off: 60;
$t.note-on:  62;
$t.note-on:  64;
$t.dt:          200; # Wait 200 MIDI pulses before subsequent events.
$t.note-off: 62;
$t.note-off: 64;
```

#### ch

Channel (ch) sets the MIDI channel to use.

The ch value is from 0 to 15. The default is 0.

```raku
    # Set on instantiation.
my $t = Track.new(:ch(1));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.ch: 1;
```

#### vol_note-off

vol_note-off sets the note-off volume.

The vol_note-off value is from 0 to 127. The default is 0.

Note: A volume for a note-off seems weird, but it can change the sound
on certain instruments like an organ on which notes can be depressed
at different speeds.

```raku
    # Set on instantiation.
my $t = Track.new(:vol_note-off(10));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.vol_note-off: 10;
```

#### vol_note-on

vol_note-on sets the note-on volume.

The vol_note-on value is from 0 to 127. The default is 0.

```raku
    # Set on instantiation.
my $t = Track.new(:vol_note-on(60));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.vol_note-on: 60;
```

### Methods

#### text

The text method adds any type of text to a track.

```raku
my $t = Track.new;
$t.text: 'Lorem ipsum dolor sit amet.';
```

#### lyric

The lyric method adds a lyric anywhere on the track.

```raku
my $t = Track.new;
$t.lyric: 'one';
```

#### marker

The marker method allows you to mark the beginning of important
sequences in a track. E.g. section I, section II, outro, etc.

```raku
my $t = Track.new;
$t.marker: 'section I';
```

#### cue

The cue method adds a cue anywhere on the track.

```raku
my $t = Track.new;
$t.cue: 'door slam';
```

#### program

The program method adds a program name anywhere on the track.

```raku
my $t = Track.new;
$t.program: 'electric piano';
```

#### port

The port method adds a MIDI port name anywhere on the track.

```raku
my $t = Track.new;
$t.port: 'MIDI Out 1';
```

#### tempo

The tempo method sets the MIDI tempo. It accepts one argument: The
tempo in microseconds per quarter note. You can either set it with a
value from 0 to 16777215, or use the quarter notes per minute operator
defined earlier in this file. The default value is 500000 which is
equivalent to a tempo of 120 quarter notes per minute.

```raku
my $t = Track.new;
$t.tempo: 1000000; # Set the tempo to 60 quarter notes per minute.
$t.tempo: ♩120;    # Set the tempo to 120 quarter notes per minute.
```

#### time-signature

The time-signature method sets the MIDI time-signature. It accepts
three optional arguments:

1. The time-signature set using the time-signature operator defined
   earlier in this file. The default is 4\4.

2. The pulses per metronome click (PPMC). This value can be from
   0 to 255. The default is 24.

3. 32nds per quarter note. This value can be from 0 to 255.
   The default is 8.

```raku
my $t = Track.new;
$t.time-signature: 3\4;
$t.time-signature: 4\4, 48;
$t.time-signature: 2\8, 32, 12;
```

#### note-off

The note-off method creates a note off. It accepts two arguments: The
note number from 0 to 127 (required), and the vol_note-off from 0 to
127 (optional). The default vol_note-off is the one set by the
vol_note-off parameter. If vol_note-off is set by this note-off
method, it will also set the vol_note-off parameter of the Track class
for the next note-off events.

```raku
my $t = Track.new;
$t.note-off: 60;      # vol_note-off == 0
$t.note-off: 62, 120; # vol_note-off == 120
$t.note-off: 64;      # vol_note-off == 120
```

#### note-on

The note-on method creates a note on. It accepts two arguments: The
note number from 0 to 127 (required), and the vol_note-on from 0 to
127 (optional). The default vol_note-on is the one set by the
vol_note-on parameter. If vol_note-on is set by this note-on method,
it will also set the vol_note-on parameter of the Track class for the
next note-on events.

```raku
my $t = Track.new;
$t.note-on: 60;      # vol_note-on == 127
$t.note-on: 62, 100; # vol_note-on == 100
$t.note-on: 64;      # vol_note-on == 100
```

#### aftertouch

The aftertouch method adds aftertouch to a given note.

The first argument is the note number from 0 to 127. The second
argument is the aftertouch amount from 0 to 127.

```raku
my $t = Track.new;
$t.aftertouch: 60, 100;
```

#### controller

The controller method is used to set a controller MIDI event.

The first argument is the controller number from 0 to 127. The second
argument is the controller value also from 0 to 127.

```raku
my $t = Track.new;
$t.controller: 8, 100; # Balance of 100.
```

#### pan

The pan method pans a channel. It takes a value from 0 to 127: 0 being
hard left, 64 being center, and 127 being hard right.

Pan is a wrapper for the controller method with a controller value of
10.

Note: If you wish to pan various tracks in different ways to create
a stereophonic image, each track must be on a different channel since
the pan methods is a controller and acts on a channel, not on a track.

```raku
my $t = Track.new;
$t.pan: 20; # Left pan.
```

#### pitch-bend

The pitch-bend method applies a pitch bend to the current channel. It
takes an optional argument from 0 to 16383. Values below 8192 bend the
pitch downwards, and values above 8192 bend the pitch upwards. If no
argument is given, the pitch bend returns to its default value of 8192
which is no pitch bend. The pitch range may vary from instrument to
instrument, but is usually +/- 2 semitones.

```raku
my $t = Track.new;
$t.pitch-bend: 0; # Bends the pitch as low as possible.
$t.pitch-bend;    # Removes pitch bend by return to the default: 8192.
```

#### render

The render method renders the MIDI track information gathered up to
that point. It is used to pass the track's MIDI data to the Song
class.

```raku
my $t = Track.new;
$t.note-on:  60;
$t.dt:           128;
$t.note-off: 60;

my $f = Song.new;
$f.add-track($t.render);
```

## Running Tests

To run all tests, simply use the following command in the root of
MIDI::Make.

```
➤ raku t/all.rakutest
```

Alternatively, you can use
[Test::Selector](https://raku.land/zef:lucs/Test::Selector) to
selectively run tests.

```
➤ tsel     :: Run all tests.
➤ tsel s1  :: Run the s1 test.
➤ tsel s\* :: Run all s tests.
```

## Resources

- [Official MIDI Specification](https://www.midi.org/specifications)
- [One-pager MIDI Specification](https://github.com/colxi/midi-parser-js/wiki/MIDI-File-Format-Specifications)
- [MIDI Files Specification](http://www.somascape.org/midi/tech/mfile.html)
- [MIDI Beat Time Considerations](https://majicdesigns.github.io/MD_MIDIFile/page_timing.html)
- [MIDI Timing](https://paxstellar.fr/2020/09/11/midi-timing)

## License

MIT, copyright © 2022 Pierre-Emmanuel Lévesque
