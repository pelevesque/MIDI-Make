[![Actions Status](https://github.com/pelevesque/MIDI-Make/actions/workflows/test.yml/badge.svg)](https://github.com/pelevesque/MIDI-Make/actions)

# MIDI::Make

A Raku module to make MIDI files.

## Synopsis

```raku
use MIDI::Make :shortnames;

my $t = Track.new;
$t.copyright:   'c 2023 anonymous';
$t.name:        'melody';
$t.instrument:  'piano';
$t.ch:           1;
$t.marker:               'section I';
$t.text:         'Lorem ipsum dolor sit amet.';
$t.tempo:        ♩80;
$t.time:         3\2;
$t.note-on:      60;
$t.dt:               128;
$t.note-off:     60;
$t.vol_note-on:  80;
$t.vol_note-off: 10;
$t.note-on:      72;
$t.dt:           128;
$t.note-off:     72;

my $f = File.new(:PPQ(96));
$f.add-track($t.render);

    # Print the MIDI contents.
say $f.render;

    # Save the MIDI contents to file.
spurt 'file.mid', $f.render;
```

# Versioning

MIDI::Make uses [Semantic Versioning](https://semver.org).

# Installation

You can install MIDI::Make using [Zef](https://github.com/ugexe/zef).

```
➤ zef install MIDI::Make
```

## Import

There are two ways to import MIDI::Make; without or with the
shortnames tag. Without the shortnames tag, the File and Track classes
must be called with their respective FQN (Fully Qualified Name). By
using the shortnames tag, it becomes possible to simply use File or
Track.

```raku
use MIDI::Make;

    # Only the FQN is available for the File and Track classes.
my $f = MIDI::Make::File.new;
my $t = MIDI::Make::Track.new;
```

```raku
use MIDI::Make :shortnames;

    # FQN and Shortnames are available for the File and Track classes.
my $f = File.new;
my $t = Track.new;
```

## Usage

MIDI::Make works by creating the File class and then populating it
with zero or more tracks created using the Track class. The resulting
MIDI information can be outputed using the File class's render method.

## The File class

The File class is used to store and modify MIDI information in order
to create a MIDI file. It has some optional parameters, the add-track
method to add tracks, and the render method to output the MIDI
information created up to that point.

```raku
    # Instantiating without parameters.
my $f = File.new;
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
my $f = File.new(:format(0));
```

```raku
    # Set after instantiation.
my $f = File.new;
$f.format: 0;
```

#### time-division

The time-division parameter defines how MIDI time will be divided.

It can have two values: quarter for quarter notes, and frame. The
default is quarter.

```raku
    # Set on instantiation.
my $f = File.new(:time-division('frame'));
```

```raku
    # Set after instantiation.
my $f = File.new;
$f.time-division: 'frame';
```

#### PPQ (pulses per quarter note)

The PPQ parameter sets the pulses per quarter note of the
time-division parameter when the latter is set to quarter. If
time-division is set to frame, PPQ is ignored.

The PPQ value is from 0 to 32767. The default is 48.

```raku
    # Set on instantiation.
my $f = File.new(:PPQ(96));
```

```raku
    # Set after instantiation.
my $f = File.new;
$f.PPQ: 96;
```

#### FPS (frames per second)

The FPS parameter sets the frames per second of the time-division
parameter when the latter is set to frame. If time-division is set to
quarter, FPS is ignored.

FPS can have four values: 24, 25, 29.97, or 30. The default is 24.

```raku
    # Set on instantiation.
my $f = File.new(:time-division('frame'), :FPS(30));
```

```raku
    # Set after instantiation.
my $f = File.new;
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
my $f = File.new(:time-division('frame'), :PPF(8));
```

```raku
    # Set after instantiation.
my $f = File.new;
$f.time-division: 'frame';
$f.PPF: 8;
```

### Methods

#### add-track

The add-track method accepts a rendered track, and adds it to the File
class.

```raku
    # Create a track.
my $t = Track.new;
$t.note-on:  60;
$t.dt:           100;
$t.note-off: 60;

    # Add it to the File class.
my $f = File.new;
$f.add-track($t.render);
```

#### render

The render method renders the MIDI file information gathered up to
that point.

```raku
my $f = File.new;
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
the Track class's time method.

```raku
$t.time: 3\8;
```

## The Track class

The Track class is used to create a MIDI track which can then be added
to the File class.

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
my $t = Track.new(:copyright('c 2023 anonymous'));
```

```raku
    # Set after instantiation.
my $t = Track.new;
$t.copyright: 'c 2023 anonymous';
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
in the Track class: tempo, time, note-off, and note-on. This is done
so that you can enter many MIDI events consecutively before setting a
new dt.

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

#### marker

The marker method allows you to mark the beginning of important
sequences in a track. E.g. section I, section II, outro, etc.

```raku
my $t = Track.new;
$t.marker: 'section I';
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

#### time

The time method sets the MIDI time-signature. It accepts three
optional arguments:

1. The time-signature set using the time-signature operator defined
   earlier in this file. The default is 4\4.

2. The pulses per metronome click (PPMC). This value can be from
   0 to 255. The default is 24.

3. 32nds per quarter note. This value can be from 0 to 255.
   The default is 8.

```raku
my $t = Track.new;
$t.time: 3\4;
$t.time: 4\4, 48;
$t.time: 2\8, 32, 12;
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

#### render

The render method renders the MIDI track information gathered up to
that point. It is used to pass the track's MIDI data to the File
class.

```raku
my $t = Track.new;
$t.note-on:  60;
$t.dt:           128;
$t.note-off: 60;

my $f = File.new;
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
➤ tsel f1  :: Run the f1 test.
➤ tsel f\* :: Run all f tests.
```

## Resources

- [Official MIDI Specification](https://www.midi.org/specifications)
- [MIDI Files Specification](http://www.somascape.org/midi/tech/mfile.html)
- [MIDI Beat Time Considerations](https://majicdesigns.github.io/MD_MIDIFile/page_timing.html)
- [MIDI Timing](https://paxstellar.fr/2020/09/11/midi-timing)
