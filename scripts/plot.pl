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
	'font_size=i',
	'font_file=s',
	'help',
	'input_file=s',
	'output_file=s',
	'sister_step=i',
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
	-font_size $integer
	-font_file $path2font
	-help
	-input_file $in_file
	-output_file $out_file
	-sister_step $integer
	-verbose $integer

All switches can be reduced to a single letter.

Exit value: 0.

=head1 OPTIONS

=over 4

=item o -font_size $integer

The pointsize of the font.

=item o -font_file $path2font

The path to a font file.

Default: /usr/local/share/fonts/truetype/gothic.ttf

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

=item o -sister_step $integer

This is the # of pixels (vertically) between sisters.

Default: 30.

=item o -verbose $integer

Set to 1 to display progress.

Default: 0 (no output).

=back

=cut
