#!/usr/bin/env perl
#
# I'm using V 6.9.3.
# See http://savage.net.au/ImageMagick/html/Installation.html.

use strict;
use warnings;

use Image::Magick;

# ----------------

my($out_file_name)	= shift || die "Usage: $0 output_file_name \n";
my($font_file)		= '/usr/local/share/fonts/truetype/gothic.ttf';
my($font_size)		= 16;
my($frame_color)	= 'purple';
my($title)			= 'The diversity of hesperornithiforms. From Bell and Chiappe, 2015';
my($maximum_x)		= 1000;
my($maximum_y)		= 100;

# Warning:
# o new(geometry => "${maximum_x}x$maximum_y") does not work.
# o new(width => $maximum_x, height => $maximum_y) does not work.
# o new() and Set(geometry => "${maximum_x}x$maximum_y") does not work.
# o new() and Set (width => $maximum_x, height => $maximum_y) does not work.
# But:
# o new(size => "${maximum_x}x$maximum_y") does work.
# o new() and Set(size => "${maximum_x}x$maximum_y") does work.

my($image) = Image::Magick -> new(size => "$maximum_x x $maximum_y");

print "Created image of size ($maximum_x, $maximum_y). \n";

# Warning:
# The following line is mandatory before the code below will work.
# Of course, the color does not have to be white.
# Without this line, the image has a size of (0, 0) or, perhaps, (1, 1).

my($result) = $image -> Read('canvas:white');

die $result if $result;

# Try Draw instead of Border. The problem will the latter is that
# it adds the border to the outsize of the image, changing its size.

#$result = $image -> Border(geometry => '2x2', fill => 'purple');

my(@x) = (0, ($maximum_x - 1), ($maximum_x - 1), 0);
my(@y) = (0, 0, ($maximum_y - 1), ($maximum_y - 1) );

$result = $image -> Draw
			(
				fill		=> 'none',
				primitive	=> 'polyline',
				points		=> "$x[0],$y[0] $x[1],$y[1] $x[2],$y[2] $x[3],$y[3] $x[0],$y[0]",
				stroke		=> $frame_color,
				strokewidth	=> 2,
			);

die $result if $result;

print "Annotating with font $font_file. \n";

my(@metrics) = $image -> QueryFontMetrics
				(
					font		=> $font_file,
					pointsize	=> $font_size,
					text		=> $title,
					x			=> 0,
					y			=> 0,
				);

my(@metric_label) = (qw/
character_width
character_height
ascender
descender
text_width
text_height
maximum_horizontal_advance
bounds_x1
bounds_y1
bounds_x2
bounds_y2
origin_x
origin_y
/);

print "Title metrics: \n", join("\n", map{"$_: $metric_label[$_]: $metrics[$_]"} 0 .. $#metrics), ". \n";

# Put the title in the center.

my($title_x)	= int( ($maximum_x - $metrics[4]) / 2);
my($title_y)	= int( ($maximum_y - $font_size) / 2);

print "Point at which to start title: ($title_x, $title_y), using gravity 'west'. \n";

$result = $image -> Annotate
			(
				font		=> $font_file,
				gravity		=> 'west',
				pointsize	=> $font_size,
				stroke		=> 'blue',
				strokewidth	=> 1,
				text		=> $title,
				x			=> $title_x,
				y			=> $title_y,
			);

die $result if $result;

my($count) = $image -> Write($out_file_name);

print "Wrote $out_file_name. \n";
