[![Actions Status](https://github.com/pelevesque/MIDI-Make/actions/workflows/test.yml/badge.svg)](https://github.com/pelevesque/MIDI-Make/actions)

# MIDI::Make

A [Raku](https://www.raku.org) module to make MIDI files.

## Synopsis

```raku
use MIDI::Make;

my \t = Track.new;
t.copyright:      'c 2022 anonymous';
t.name:           'melody';
t.instrument:     'piano';
t.controller:     8, 100;
t.program-name:   'electric piano';
t.port:           'MIDI Out 1';
t.channel         1;
t.program-change: 100;
t.aftertouch:     100;
t.pitch-bend:     0;
t.marker:                 'section I';
t.text:           'Lorem ipsum dolor sit amet.';
t.key-signature:  2♭, minor;
t.tempo:          ♩80;
t.time-signature: 3\2;
t.aftertouch:     100, 53;
t.note-on:        60;
t.lyric:          'one';
t.delta-time:         128;
t.note-off:       60;
t.cue:            'door slam';
t.velocity-on:    80;
t.velocity-off:   10;
t.note-on:        72;
t.lyric:          'two';
t.delta-time:         128;
t.note-off:       72;
t.sysex:          <0A 29 1E>;
t.add-bytes:      <00 F0 0A 29 1E F7>;

my \s = Song.new(:PPQ(96));
s.add-track(t.render);

    # Print the MIDI contents.
say s.render;

    # Save the MIDI contents to file.
spurt 'file.mid', s.render;
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
my \s = Song.new;
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
my \s = Song.new(:format(0));
```

```raku
    # Set after instantiation.
my \s = Song.new;
s.format: 0;
```

#### time-division

The time-division parameter defines how MIDI time will be divided.

It can have two values: quarter for quarter notes, and frame. The
default is quarter.

```raku
    # Set on instantiation.
my \s = Song.new(:time-division('frame'));
```

```raku
    # Set after instantiation.
my \s = Song.new;
s.time-division: 'frame';
```

#### PPQ (pulses per quarter note)

The PPQ parameter sets the pulses per quarter note of the
time-division parameter when the latter is set to quarter. If
time-division is set to frame, PPQ is ignored.

The PPQ value is from 0 to 32767. The default is 48.

```raku
    # Set on instantiation.
my \s = Song.new(:PPQ(96));
```

```raku
    # Set after instantiation.
my \s = Song.new;
s.PPQ: 96;
```

#### FPS (frames per second)

The FPS parameter sets the frames per second of the time-division
parameter when the latter is set to frame. If time-division is set to
quarter, FPS is ignored.

FPS can have four values: 24, 25, 29.97, or 30. The default is 24.

```raku
    # Set on instantiation.
my \s = Song.new(:time-division('frame'), :FPS(30));
```

```raku
    # Set after instantiation.
my \s = Song.new;
s.time-division: 'frame';
s.FPS: 30;
```

#### PPF (pulses per frame)

The PPF parameter sets the pulses per frame of the time-division
parameter when the latter is set to frame. If time-division is set to
quarter, PPF is ignored.

The PPF value is from 0 to 255. The default is 4.

```raku
    # Set on instantiation.
my \s = Song.new(:time-division('frame'), :PPF(8));
```

```raku
    # Set after instantiation.
my \s = Song.new;
s.time-division: 'frame';
s.PPF: 8;
```

### Methods

#### add-track

The add-track method accepts a rendered track, and adds it to the Song
class.

```raku
    # Create a track.
my \t = Track.new;
t.note-on:    60;
t.delta-time:     100;
t.note-off:   60;

    # Add it to the Song class.
my \s = Song.new;
s.add-track(t.render);
```

#### render

The render method renders the MIDI file information gathered up to
that point.

```raku
my \s = Song.new;
say s.render;
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
my \t = Track.new;
t.tempo: 1000000;

    # 60 QPM using the MIDI::Make operator.
my \t = Track.new;
t.tempo: ♩60;
```

### \

The time-signature operator is used to specify a time-signature for
the Track class's time-signature method.

```raku
my \t = Track.new;
t.time-signature: 3\8;
```

## The Track class

The Track class is used to create a MIDI track which can then be added
to the Song class.

```raku
    # Instantiating without parameters.
my \t = Track.new;
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
my \t = Track.new(:copyright('c 2022 anonymous'));
```

```raku
    # Set after instantiation.
my \t = Track.new;
t.copyright: 'c 2022 anonymous';
```

#### name

The name parameter lets you set the track's name using
ASCII characters.

```raku
    # Set on instantiation.
my \t = Track.new(:name('melody'));
```

```raku
    # Set after instantiation.
my \t = Track.new;
t.name: 'melody';
```

#### delta-time

Delta time sets the time in MIDI pulses between MIDI events.

The delta-time value is from O to 268435455. The default is 0.

Note: Although it's possible to instantiate delta-time to a value
other than 0, usually you will start a MIDI file with a MIDI event,
and not a period of time.

```raku
    # Set on instantiation.
my \t = Track.new(:delta-time(100));
```

```raku
    # Set after instantiation.
my \t = Track.new;
t.delta-time: 100;
```

Delta-time is automatically set to 0 after each of the MIDI events
implemented in the Track class. This is done so that you can enter
many MIDI events consecutively before setting a new delta-time.

```raku
my \t = Track.new;
t.note-on:    60;
t.delta-time:     100; # Wait 100 MIDI pulses before following events.
t.note-off:   60;
t.note-on:    62;
t.note-on:    64;
t.delta-time:     200; # Wait 200 MIDI pulses before following events.
t.note-off:   62;
t.note-off:   64;
```

#### channel

Channel sets the MIDI channel to use.

The channel value is from 0 to 15. The default is 0.

```raku
    # Set on instantiation.
my \t = Track.new(:channel(1));
```

```raku
    # Set after instantiation.
my \t = Track.new;
t.channel: 1;
```

#### velocity-off

velocity-off sets the note-off velocity.

The velocity-off value is from 0 to 127. The default is 0.

Note: A velocity for a note-off seems weird, but it can change the
sound on certain instruments like an organ on which notes can be
depressed at different speeds.

```raku
    # Set on instantiation.
my \t = Track.new(:velocity-off(10));
```

```raku
    # Set after instantiation.
my \t = Track.new;
t.velocity-off: 10;
```

#### velocity-on

velocity-on sets the note-on velocity.

The velocity-on value is from 0 to 127. The default is 0.

```raku
    # Set on instantiation.
my \t = Track.new(:velocity-on(60));
```

```raku
    # Set after instantiation.
my \t = Track.new;
t.velocity-on: 60;
```

### Methods

#### text

The text method adds any type of text to a track.

```raku
my \t = Track.new;
t.text: 'Lorem ipsum dolor sit amet.';
```

#### instrument

The instrument method lets you set the track's instrument using
ASCII characters.

```raku
my \t = Track.new;
t.instrument: 'piano';
```

#### lyric

The lyric method adds a lyric anywhere on the track.

```raku
my \t = Track.new;
t.lyric: 'one';
```

#### marker

The marker method allows you to mark the beginning of important
sequences in a track. E.g. section I, section II, outro, etc.

```raku
my \t = Track.new;
t.marker: 'section I';
```

#### cue

The cue method adds a cue anywhere on the track.

```raku
my \t = Track.new;
t.cue: 'door slam';
```

#### program-name

The program-name method adds a program name anywhere on the track.

```raku
my \t = Track.new;
t.program-name: 'electric piano';
```

#### port

The port method adds a MIDI port name anywhere on the track.

```raku
my \t = Track.new;
t.port: 'MIDI Out 1';
```

#### tempo

The tempo method sets the MIDI tempo. It accepts one argument: The
tempo in microseconds per quarter note. You can either set it with a
value from 0 to 16777215, or use the quarter notes per minute operator
defined earlier in this file. The default value is 500000 which is
equivalent to a tempo of 120 quarter notes per minute.

```raku
my \t = Track.new;
t.tempo: 1000000; # Set the tempo to 60 quarter notes per minute.
t.tempo: ♩120;    # Set the tempo to 120 quarter notes per minute.
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
my \t = Track.new;
t.time-signature: 3\4;
t.time-signature: 4\4, 48;
t.time-signature: 2\8, 32, 12;
```

#### key-signature

The key-signature method sets the key-signature of the piece. It
accepts two optional arguments:

1. The key which is defined as the number of accidentals. This value
   can be from -7 to 7 where -1 to -7 is the number of flats, and
   1 to 7 is the number of sharps. It is also possible to use
   1♭, 2♭ ... 7♭ instead of -1 to -7 for flats, and 1♯, 2♯ ... 7♯
   instead of 1 to 7 for sharps. You can also use 0♭ or 0♯ instead of
   0.

2. The mode which is either 0 for major, or 1 for minor. MIDI::Make
   provides you with the Modes enums <major minor> that you may use
   instead of 0 and 1.

```raku
my \t = Track.new;
t.key-signature: -2, 1;     # G minor
t.key-signature: 2♭, 1;     # G minor with unicode number of flats.
t.key-signature: 2♭, minor: # G minor with Modes enum.
```

#### note-off

The note-off method creates a note off. It accepts two arguments: The
note number from 0 to 127 (required), and the velocity-off from
0 to 127 (optional). The default velocity-off is the one set by
the velocity-off parameter.

```raku
my \t = Track.new;
t.note-off: 60;     # velocity-off == 0
t.note-off: 62, 10; # velocity-off == 10
t.note-off: 64;     # velocity-off == 0
t.velocity-off: 10;
t.note-off: 66;     # velocity-off == 10
```

#### note-on

The note-on method creates a note on. It accepts two arguments: The
note number from 0 to 127 (required), and the velocity-on from
0 to 127 (optional). The default velocity-on is the one set by
the velocity-on parameter.

```raku
my \t = Track.new;
t.note-on: 60;      # velocity-on == 127
t.note-on: 62, 100; # velocity-on == 100
t.note-on: 64;      # velocity-on == 127
t.velocity-on: 100;
t.note-on: 66;      # velocity-on == 100
```

#### aftertouch

The aftertouch method is a multi method for both note aftertouch, and
channel aftertouch.

For a note aftertouch, you provide two arguments: The aftertouch
amount from 0 to 127, and the note number from 0 to 127.

For a channel aftertouch, you simply provide the aftertouch amount.

```raku
my \t = Track.new;
t.aftertouch: 100, 53; # note aftertouch
t.aftertouch: 100;     # channel aftertouch
```

#### controller

The controller method is used to set a controller MIDI event.

The first argument is the controller number from 0 to 127. The second
argument is the controller value also from 0 to 127.

```raku
my \t = Track.new;
t.controller: 8, 100; # balance_MSB of 100.
```

You can also call specific controllers using the following methods:

| #       | method                 | value   | use         | definition                             |
|:--------|:-----------------------|:--------|:------------|:---------------------------------------|
| 0       | bank-select_MSB        | 0-127   | MSB         | Change patch banks.                    |
| 1       | modulation_MSB         | 0-127   | MSB         | Create a vibrato effect.               |
| 2       | breath_MSB             | 0-127   | MSB         | Breath controller.                     |
| 3       | -                      | -       | -           | -                                      |
| 4       | foot-pedal_MSB         | 0-127   | MSB         | Foot pedal data.                       |
| 5       | portamento-time_MSB    | 0-127   | MSB         | Control portamento rate.               |
| 6       | data-entry_MSB         | 0-127   | MSB         | Control value for NRPN/RPN parameters. |
| 7       | channel-volume_MSB     | 0-127   | MSB         | Control the channel volume.            |
| 8       | balance_MSB            | 0-127   | MSB         | Control left/right balance for stereo. |
| 9       | -                      | -       | -           | -                                      |
| 10      | pan_MSB                | 0-127   | MSB         | Control left/right balance for mono.   |
| 11      | expression_MSB         | 0-127   | MSB         | Expression is a percentage of volume.  |
| 12      | effect-control_1_MSB   | 0-127   | MSB         | Control an effect parameter.           |
| 13      | effect-control_2_MSB   | 0-127   | MSB         | Control an effect parameter.           |
| 14-15   | -                      | -       | -           | -                                      |
| 16      | general-control_1_MSB  | 0-127   | MSB         | General purpose controller.            |
| 17      | general-control_2_MSB  | 0-127   | MSB         | General purpose controller.            |
| 18      | general-control_3_MSB  | 0-127   | MSB         | General purpose controller.            |
| 19      | general-control_4_MSB  | 0-127   | MSB         | General purpose controller.            |
| 20-31   | -                      | -       | -           | -                                      |
| 32      | bank-select_LSB        | 0-127   | LSB         | Change patch banks.                    |
| 33      | modulation_LSB         | 0-127   | LSB         | Create a vibrato effect.               |
| 34      | breath_LSB             | 0-127   | LSB         | Breath controller.                     |
| 35      | -                      | -       | -           | -                                      |
| 36      | foot-pedal_LSB         | 0-127   | LSB         | Foot pedal data.                       |
| 37      | portamento-time_LSB    | 0-127   | LSB         | Control portamento rate.               |
| 38      | data-entry_LSB         | 0-127   | LSB         | Control value for NRPN/RPN parameters. |
| 39      | channel-volume_LSB     | 0-127   | LSB         | Control the channel volume.            |
| 40      | balance_LSB            | 0-127   | LSB         | Control left/right balance for stereo. |
| 41      | -                      | -       | -           | -                                      |
| 42      | pan_LSB                | 0-127   | LSB         | Control left/right balance for mono.   |
| 43      | expression_LSB         | 0-127   | LSB         | Expression is a percentage of volume.  |
| 44      | effect-control_1_LSB   | 0-127   | LSB         | Control an effect parameter.           |
| 45      | effect-control_2_LSB   | 0-127   | LSB         | Control an effect parameter.           |
| 46-47   | -                      | -       | -           | -                                      |
| 48      | general-control_1_LSB  | 0-127   | LSB         | General purpose controller.            |
| 49      | general-control_2_LSB  | 0-127   | LSB         | General purpose controller.            |
| 50      | general-control_3_LSB  | 0-127   | LSB         | General purpose controller.            |
| 51      | general-control_4_LSB  | 0-127   | LSB         | General purpose controller.            |
| 52-63   | -                      | -       | -           | -                                      |
| 64      | hold_1-pedal           | <63=off | 64>=0n      | Sustain pedal 1 on/off switch.         |
| 65      | portamento             | <63=off | 64>=0n      | Portmento on/off switch.               |
| 66      | sostenuto              | <63=off | 64>=0n      | Sostenuto on/off switch.               |
| 67      | soft-pedal             | <63=off | 64>=0n      | Soft pedal on/off switch.              |
| 68      | legato-footswitch      | <63=off | 64>=0n      | Legato on/off switch.                  |
| 69      | hold_2-pedal           | <63=off | 64>=0n      | Sustain pedal 2 on/off switch.         |
| 70      | sound-control_1        | 0-127   | LSB         | Sound control. (variation)             |
| 71      | sound-control_2        | 0-127   | LSB         | Sound control. (resonance)             |
| 72      | sound-control_3        | 0-127   | LSB         | Sound control. (release time)          |
| 73      | sound-control_4        | 0-127   | LSB         | Sound control. (attack time)           |
| 74      | sound-control_5        | 0-127   | LSB         | Sound control. (cutoff frequency)      |
| 75      | sound-control_6        | 0-127   | LSB         | Generic sound control.                 |
| 76      | sound-control_7        | 0-127   | LSB         | Generic sound control.                 |
| 77      | sound-control_8        | 0-127   | LSB         | Generic sound control.                 |
| 78      | sound-control_9        | 0-127   | LSB         | Generic sound control.                 |
| 79      | sound-control_10       | 0-127   | LSB         | Generic sound control.                 |
| 80      | general-control_5      | 0-127   | LSB         | Generic or decay on/off switch.        |
| 81      | general-control_6      | 0-127   | LSB         | Generic or hi-pass on/off switch.      |
| 82      | general-control_7      | 0-127   | LSB         | Generic on/off switch.                 |
| 83      | general-control_8      | 0-127   | LSB         | Generic on/off switch.                 |
| 84      | portamento-control     | 0-127   | note        | Control portamento amount.             |
| 85-87   | -                      | -       | -           | -                                      |
| 88      | hi-res-velocity-prefix | 0-127   | MSB         | Extend the range of velocities.        |
| 89-90   | -                      | -       | -           | -                                      |
| 91      | effect_1-depth         | 0-127   | LSB         | Effect control. (reverb)               |
| 92      | effect_2-depth         | 0-127   | LSB         | Effect control. (tremolo)              |
| 93      | effect_3-depth         | 0-127   | LSB         | Effect control. (chorus)               |
| 94      | effect_4-depth         | 0-127   | LSB         | Effect control. (detune)               |
| 95      | effect_5-depth         | 0-127   | LSB         | Effect control. (phaser)               |
| 96      | data-increment         | N/A     | N/A         | Increment data for NRPN/RPN messages.  |
| 97      | data-decrement         | N/A     | N/A         | Decrement data for NRPN/RPN messages.  |
| 98      | NRPN_LSB               | 0-127   | LSB         | NRPN for controllers: 6, 38, 96, 97    |
| 99      | NRPN_MSB               | 0-127   | MSB         | NRPN for controllers: 6, 38, 96, 97    |
| 100     | RPN_LSB                | 0-127   | LSB         | RPN for controllers: 6, 38, 96, 97     |
| 101     | RPN_MSB                | 0-127   | MSB         | RPN for controllers: 6, 38, 96, 97     |
| 102-119 | -                      | -       | -           | -                                      |
| 120     | all-sounds-off         | 0       | -           | Mute all sounds.                       |
| 121     | reset-controllers      | 0       | -           | Reset all controllers to defaults.     |
| 122     | local-switch           | 0=off   | 127=on      | MIDI workstation on/off switch.        |
| 123     | all-notes-off          | 0       | -           | Mute all sounding notes.               |
| 124     | omni-mode-off          | 0       | -           | Set to omni mode off.                  |
| 125     | omni-mode-on           | 0       | -           | Set to omni mode on.                   |
| 126     | mono-mode              | 0-127   | num-channel | Set device mode to monophonic.         |
| 127     | poly-mode              | 0       | -           | Set device mode to polyphonic.         |

Ex:

```raku
my \t = Track.new;
t.pan_MSB: 64;
```

It's also possible to call the MSB and LSB counterparts (controllers
in the range of 0-63) with one function. This permits specifying a
value between 0 and 16383 in one go.

| method            | value   | definition                             |
|:------------------|:--------|:---------------------------------------|
| bank-select       | 0-16383 | Change patch banks.                    |
| modulation        | 0-16383 | Create a vibrato effect.               |
| breath            | 0-16383 | Breath controller.                     |
| foot-pedal        | 0-16383 | Foot pedal data.                       |
| portamento-time   | 0-16383 | Control portamento rate.               |
| data-entry        | 0-16383 | Control value for NRPN/RPN parameters. |
| channel-volume    | 0-16383 | Control the channel volume.            |
| balance           | 0-16383 | Control left/right balance for stereo. |
| pan               | 0-16383 | Control left/right balance for mono.   |
| expression        | 0-16383 | Expression is a percentage of volume.  |
| effect-control_1  | 0-16383 | Control an effect parameter.           |
| effect-control_2  | 0-16383 | Control an effect parameter.           |
| general-control_1 | 0-16383 | General purpose controller.            |
| general-control_2 | 0-16383 | General purpose controller.            |
| general-control_3 | 0-16383 | General purpose controller.            |
| general-control_4 | 0-16383 | General purpose controller.            |

Ex:

```raku
my \t = Track.new;
t.pan: 3489;
```

#### program-change

Changes the program of the current channel.

It has one argument, the program number from 0 to 127.

```raku
my \t = Track.new;
t.program-change: 100; # Effect 5 in General MIDI.
```

#### pitch-bend

The pitch-bend method applies a pitch bend to the current channel. It
takes an optional argument from 0 to 16383. Values below 8192 bend the
pitch downwards, and values above 8192 bend the pitch upwards. If no
argument is given, the pitch bend returns to its default value of 8192
which is no pitch bend. The pitch range may vary from instrument to
instrument, but is usually +/- 2 semitones.

```raku
my \t = Track.new;
t.pitch-bend: 0; # Bends the pitch as low as possible.
t.pitch-bend;    # Removes pitch bend by applying the default: 8192.
```

#### sysex

The sysex method implements a simple sysex message. It takes a list
of dataBytes, and surrounds them with sysex start and end bytes:
F0 <dataBytes> F7

```raku
my \t = Track.new;
t.sysex: <0A 29 1E>;
```

#### add-bytes

The add-bytes method lets you add arbitrary bytes to the track. Unlike
other methods, it does not add delta-time nor does it reset delta-time
to 0. add-bytes is mostly useful for testing purposes.

```raku
my \t = Track.new;
t.add-bytes: <00 F0 0A 29 1E F7>;
```

#### render

The render method renders the MIDI track information gathered up to
that point. It is used to pass the track's MIDI data to the Song
class.

```raku
my \t = Track.new;
t.note-on:    60;
t.delta-time:     128;
t.note-off:   60;

my \s = Song.new;
s.add-track(t.render);
```

## Running Tests

To run all tests, simply use the following command in the root of
MIDI::Make.

```
➤ raku -Ilib t/all.rakutest
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

MIT\
Copyright 2022 Pierre-Emmanuel Lévesque
