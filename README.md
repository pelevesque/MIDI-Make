# MIDI::Make

A Raku module to make MIDI files.

## Import

```raku
use MIDI::Make;
```

## Usage

MIDI::Make works by creating a file class and then populating it with
zero or more tracks created using the track class. The resulting MIDI
information can be outputed using the render method.

## The File Class

The file class is used to store and modify MIDI information used to
create a MIDI file. It has some optional parameters, the add-track
method to add tracks, and the render method to output the MIDI
information created up to that point.

```raku
    # Instantiating without parameters.
    my $f = File.new;
```

### Parameters

Paramters can be set on instantiation, or afterwards.

#### Format

The format parameter specifies the type of MIDI file format to use.
It is an integer, and can have three values: 1, 2, or 3. The default
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

#### Time-Division

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
parameter when set to frame. If time-division is set to
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

The render method renders the MIDI file information.

```raku
    my $f = File.new;
    say $f.render;
```

----------------------------------------------------------------------

## Operators

Importing MIDI::Make creates two operators that serve as helpers.

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
the track class's time method.

```raku
    $t.time: 3\8;
```

----------------------------------------------------------------------

## The Track class

The Track class is used to create a MIDI track which can then be added
to the File class.

```raku
    # Instantiating without parameters.
    my $t = Track.new;
```

### Parameters

Paramters can be set on instantiation, or afterwards.

#### Name

With the name parameter, you can name the track using ASCII characters.

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

Delta time (dt) sets the delta time.
talk about how delta time is used...

```raku
    # Set on instantiation.
    my $t = Track.new(:dt(100));
```

```raku
    # Set after instantiation.
    my $t = Track.new;
    $t.dt: 'piano';
```

#### ch

Channel (dt) sets the channel to use. talk about how channel is used...

```raku
    # Set on instantiation.
    my $t = Track.new(:ch(2));
```

```raku
    # Set after instantiation.
    my $t = Track.new;
    $t.ch: 2;
```

#### vol_note-off

Volume note-off.

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

Volume note-on.

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

The add-track method accepts a rendered track, and adds it to the
File class.

```raku
    # Create a track then add it to the File class.
    my $t = Track.new;
    $t.note-on: 60;
    $t.dt: 100;
    $t.note-off: 60;

    my $f = File.new;
    $f.add-track($t.render);
```

## Resources

- [Official MIDI Specification](https://www.midi.org/specifications)
- [Standard MIDI File Structure](https://ccrma.stanford.edu/~craig/14q/midifile/MidiFileFormat.html)
- [Time Signature](http://midi.teragonaudio.com/tech/midifile/time.htm)
- [Time Division](https://www.recordingblogs.com/wiki/time-division-of-a-midi-file)
- [MIDI Beat Time Considerations](https://majicdesigns.github.io/MD_MIDIFile/page_timing.html)
- [MIDI timting](https://paxstellar.fr/2020/09/11/midi-timing/)
- [MIDI Files Specification](http://www.somascape.org/midi/tech/mfile.html)
