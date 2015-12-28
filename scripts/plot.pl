#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

use Pod::Usage;

use Tree::Cladogram;

# ----------------------------------------------

my($option_parser) = Getopt::Long::Parser -> new;

my(%option);

if ($option_parser -> getoptions
(
	\%option,
	'draw_frame=i',
	'font_size=i',
	'font_file=s',
	'frame_color=s',
	'help',
	'input_file=s',
	'output_file=s',
	'print_tree=i',
	'verbose=i',
) )
{
	pod2usage(1) if ($option{'help'});

	exit Tree::Cladogram -> new(%option) -> run;
}
else
{
	pod2usage(2);
}

__END__

=pod

=head1 NAME

plot.pl - Read input text file and write cladogram image file

=head1 DESCRIPTION

plt.pl plots a cladogram.

=head1 SYNOPSIS

plot.pl [options]

	Options:
	-draw_frame $Boolean
	-font_size $integer
	-font_file $path2font
	-frame_color $string
	-help
	-input_file $in_file
	-output_file $out_file
	-print_tree $Boolean
	-verbose $Boolean

All switches can be reduced to a single letter.

Exit value: 0.

=head1 OPTIONS

=over 4

=item o -draw_frame $Boolean

If set, include the frame in the output image.

Default: 0 (no frame).

=item o -font_size $integer

The pointsize of the font.

=item o -font_file $path2font

The path to a font file.

Default: /usr/local/share/fonts/truetype/gothic.ttf

=item o -frame_color $string

Specify the color of the frame, if any.

Use a word - 'blue' or a HTML color specification - '#ff0000'.

Default: '#0000ff'.

See also C<draw_frame>.

=item o -help

Print help and exit.

=item o -input_file $in_file

The path of the input text file to read.

This option is mandatory.

For sample input files, see data/*.clad.

Default: ''.

=item o -output_file $out_file

The path of the output image file to wite.

This option is mandatory.

For sample output files, see data/*.png.

Default: ''.

=item o -print_tree $Boolean

If set, /and/ if verbose it set, print the tree constructed by reading the input file.

Default: 0 (no output).

=item o -verbose $Boolean

Set to 1 to display progress.

Default: 0 (no output).

=back

=cut
