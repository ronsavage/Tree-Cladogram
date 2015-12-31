#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;

use Image::Magick;

# ----------------

my($font_file)	= '/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf';
my($font_size)	= 16;
my($title)		= 'The diversity of hesperornithiforms. From Bell and Chiappe, 2015';
my($image)		= Image::Magick -> new(width => 1000, height => 100);
my(@metrics)	= $image -> QueryFontMetrics
					(
						font		=> $font_file,
						pointsize	=> $font_size,
						text		=> $title,
						x			=> 20,
						y			=> 20,
					);

$image -> Read('canvas:white');
#$image -> Frame(fill => 'blue', width => 1, height => 1);

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

print "Title metrics: \n", join("\n", map{"$metric_label[$_]: $metrics[$_]"} 0 .. $#metrics), ". \n";

my($out_file_name)	= "$ENV{DR}/misc/test.image.magick.png";
my($count)			= $image -> Write($out_file_name);

say "Wrote $out_file_name";
