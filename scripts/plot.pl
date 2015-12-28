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
	'frame_color=s',
	'help',
	'input_file=s',
	'leaf_font_file=s',
	'leaf_font_size=i',
	'output_file=s',
	'print_tree=i',
	'title=s',
	'title_font_file=s',
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
	-frame_color $string
	-help
	-input_file $in_file
	-leaf_font_color $string
	-leaf_font_file $path2font
	-leaf_font_size $integer
	-output_file $out_file
	-print_tree $Boolean
	-title $string
	-title_font_color $string
	-title_font_file $path2font
	-verbose $Boolean

All switches can be reduced to a single letter.

Exit value: 0.

=head1 OPTIONS

=over 4

=item o -draw_frame $Boolean

If set, include the frame in the output image.

Default: 0 (no frame).

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

=item o -leaf_font_color $string

The color of the font used for the names of the leaves.

Default: '#0000ff' (blue).

=item o -leaf_font_file $path2font

The path to a font file to be used to the names of leaves.

Default: /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf.

This file ships as data/VeraBd.ttf.

=item o -leaf_font_size $integer

The pointsize of the font.

=item o -output_file $out_file

The path of the output image file to wite.

This option is mandatory.

For sample output files, see data/*.png.

Default: ''.

=item o -print_tree $Boolean

If set, /and/ if verbose it set, print the tree constructed by reading the input file.

Default: 0 (no output).

=item o -title $string

Add a title at the bottom of the image.

See scripts/plot.sh for how to protect strings-with-spaces from the shell.

Default: '' (no title).

=item o -title_font_color $string

The color of the font used for the title.

Default: '#000000' (black).

=item o -title_font_file $path2font

The path to a font file to be used for the title.

Default: /usr/share/fonts/truetype/freefont/FreeSansBold.ttf.

This file ships as data/FreeSansBold.ttf.

=item o -verbose $Boolean

Set to 1 to display progress.

Default: 0 (no output).

=back

=cut
