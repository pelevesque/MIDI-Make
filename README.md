# MIDI::Make

A Raku module to make MIDI files.

## Import

```raku
use MIDI::Make;
```

## Usage

MIDI::Make works by creating a File class and then populating it with
zero or more tracks created using the Track class. The resulting MIDI
information can be outputed using the File class's render method.

## The File Class

The File class is used to store and modify MIDI information used to
create a MIDI file. It has some optional parameters, the add-track
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
It is an integer, and can have three values: 0, 1, or 2. The default
is 1.

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

The time-division parameter can be set to quarter for quarter-notes,
or to frame. The default is quarter.

```raku
    # Set on instantiation.
    my $f = File.new(:time-division('frame'));
```

```raku
    # Set after instantiation.
    my $f = File.new;
    $f.time-division: 'frame';
```

#### PPQ (pulses per quarter-note)

The PPQ parameter sets the pulses per querter-note of the
time-division parameter when set to quarter. If time-division is set
to frame, PPQ is ignored.

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
parameter when set to frame. If time-division is set to quarter,
FPS is ignored.

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
parameter when set to frame. If time-division is set to quarter,
PPF is ignored.

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

The add-track method accepts a rendered track, and adds it to the
File class.

```raku
    # Create a track.
    my $t = Track.new;
    $t.note-on: 60;
    $t.dt: 100;
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

### ♩PM or QPM

The quarter-notes per minute operator transforms quarter-notes per
minute to microseconds per quarter-note.

This permits specifying tempo in a musical human-readable way.

```raku
    $t.tempo: 1000000; # Microseconds per quarter-note. Similar to 60♩PM.

    $t.tempo: 60♩PM; # With unicode.
    $t.tempo: 60QPM; # Without unicode.
```

### \

The time signature operator is used to specify a time signature for
the Track class's time method.

```raku
    $t.time: 3\8;
```

## The Track class

The Track class is used to create a MIDI track which can then be
added to the File class.

```raku
    # Instantiating without parameters.
    my $t = Track.new;
```

### Parameters

Parameters can be set on instantiation, or anytime afterwards.

#### name

With the name parameter, you can name the track using
ASCII characters.

```raku
    # Set on instantiation.
    my $t = Track.new(:name('piano'));
```

```raku
    # Set after instantiation.
    my $t = Track.new;
    $t.name: 'piano';
```

#### dt

Delta time (dt) sets the time in MIDI pulses between MIDI events.
Its value can be between O and 268435455. The default is 0. Although
it's possible to instantiate dt to a value other than 0, usually you
will start a MIDI file with a MIDI event, and not a period of time.

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
in the Track class: tempo, time, note-off, note-on. This is done so
that you can enter many MIDI events together before setting a new dt.

```raku
    my $t = Track.new;
    $t.note-on: 60;
    $t.dt: 100;         # Wait 100 MIDI pulses before next events.
    $t.note-off: 60;
    $t.note-on: 62;
    $t.note-on: 64;
    $t.dt: 200;         # Wait 200 MIDI pulses before next events.
    $t.note-off: 62;
    $t.note-off: 64;
```

#### ch

Channel (ch) sets the MIDI channel to use. It can be a value between
0 and 15. The default is 0.

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

vol_note-off sets the note-off volume. It can be a value between
0 and 127. The default is 0.

A volume for a note-off seems weird, but it cah change the sound on
certain instruments like an organ where notes can be depressed at
different speeds.

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

vol_note-on sets the note-on volume. It can be a value between
0 and 127. The default is 127.

```raku
    # Set on instantiation.
    my $t = Track.new(:vol_note-on(60));
```

```raku
    # Set after instantiation.
    my $t = Track.new;
    $t.vol_note-on: 60;
```

----------------------------------------------------------------------
----------------------------------------------------------------------

### Methods

#### tempo

#### time

#### note-off

#### note-on

## Resources

- [Official MIDI Specification](https://www.midi.org/specifications)
- [Standard MIDI File Structure](https://ccrma.stanford.edu/~craig/14q/midifile/MidiFileFormat.html)
- [Time Signature](http://midi.teragonaudio.com/tech/midifile/time.htm)
- [Time Division](https://www.recordingblogs.com/wiki/time-division-of-a-midi-file)
- [MIDI Beat Time Considerations](https://majicdesigns.github.io/MD_MIDIFile/page_timing.html)
- [MIDI timting](https://paxstellar.fr/2020/09/11/midi-timing/)
- [MIDI Files Specification](http://www.somascape.org/midi/tech/mfile.html)
