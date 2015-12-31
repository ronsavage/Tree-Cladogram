#!/usr/bin/env perl

use strict;
use warnings;

use Image::Magick;

# ---------------------------------------------------------

my($output_file_name)	= 'data/im-hax-annotate-3.png';
my($image)				= Image::Magick -> new(size => '300x300');
my($result)				= $image -> Read('xc:white');
die $result if $result;

$result = $image -> Border(geometry => '2x2', fill => 'cyan');
die $result if $result;

my($x_center, $y_center)	= (150, 150);
my($x_radius, $y_radius)	= (30, 30);
my($x_left, $y_left)		= ($x_center - ($x_radius / 2), $y_center - ($y_radius / 2) );
my($x_right, $y_right)		= ($x_center + ($x_radius / 2), $y_center + ($y_radius / 2) );

$result = $image -> Set("Pixel[$x_center,$y_center]" => 'red');
die $result if $result;

# Disable SVG code, for the moment.

=pod
$result = $image -> Draw
(
	primitive	=> 'path', stroke => 'blue', fill => 'none', strokewidth => 3,
	points		=> "M $x_left,$y_left A $x_radius,$y_radius 0 0 0 $x_right,$y_right"
);
die $result if $result;

$result = $image -> Draw
(
	primitive	=> 'path', stroke => 'blue', fill => 'none', strokewidth => 3,
	points		=> "M $x_left,$y_left A $x_radius,$y_radius 0 1 1 $x_right,$y_right"
);
die $result if $result;
=cut

# Use simple drawing code.

$result = $image -> Draw
(
	primitive	=> 'circle', stroke => 'blue', fill => 'none', strokewidth => 3,
	points		=> "$x_center,$y_center $x_right,$y_right"
);
die $result if $result;

my($x, $y, $angle);

for my $x_offset (-1, 1)
{
	for my $y_offset (-1, 1)
	{
		$x		= $x_center + ($x_offset * $x_radius);
		$y		= $y_center + ($y_offset * $y_radius);

		if ($x_offset == -1)
		{
			$angle = ($y_offset == -1) ? 225 : 135;
		}
		else
		{
			$angle = ($y_offset == -1) ? 315 : 45;
		}

		# stroke => 'none', fill => 'red' usually produces
		# sharper text than stroke => 'red', fill => 'red'.

		$result	= $image -> Annotate
		(
			text		=> "($x,$y)",
			font		=> 'Arial',
			stroke		=> 'none',
			strokewidth	=> 2,
			fill		=> 'red',
			x			=> $x,
			y			=> $y,
			rotate		=> $angle
		);
	}
}

$result = $image -> Write($output_file_name);
die $result if $result;
print "Wrote: $output_file_name. \n";
