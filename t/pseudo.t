# Temporary pseudo testing code.

# --------------------------------------------------------------------
# Empty File: default

my $t = File.new;
$t.render.say;

4D 54 68 64 00 00 00 06 00 01 00 00 00 30

# --------------------------------------------------------------------
# Empty File: format => 2

my $t = File.new(format => 2);
$t.render.say;

4D 54 68 64 00 00 00 06 00 02 00 00 00 30

# --------------------------------------------------------------------
# Empty File: time-division => 'frame'

my $t = File.new(time-division => 'frame');
$t.render.say;

4D 54 68 64 00 00 00 06 00 01 00 00 E8 04

# --------------------------------------------------------------------
# Empty Track

my $t = Track.new;
$t.render.say;

4D 54 72 6B 00 00 00 04 00 FF F2 00
