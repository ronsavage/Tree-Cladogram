package Tree::Cladogram;

use File::Slurper 'read_lines';

use Moo;

use Tree::DAG_Node;

use Types::Standard qw/Any Int Str/;

has branch_color =>
(
	default  => sub{return '#7e7e7e'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has branch_width =>
(
	default  => sub{return 3},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has draw_frame =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has debug =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has final_x_step =>
(
	default  => sub{return 30},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has frame_color =>
(
	default  => sub{return '#0000ff'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has input_file =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has leaf_font_color =>
(
	default  => sub{return '#0000ff'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has leaf_font_file =>
(
	default  => sub{return '/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has leaf_font_size =>
(
	default  => sub{return 16},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has left_margin =>
(
	default  => sub{return 15},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has maximum_x =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has maximum_y =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has minimum_y =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has output_file =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has print_tree =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has root =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has title =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has title_font_color =>
(
	default  => sub{return '#000000'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has title_font_file =>
(
	default  => sub{return '/usr/share/fonts/truetype/freefont/FreeSansBold.ttf'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has title_font_size =>
(
	default  => sub{return 16},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has title_width =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has top_margin =>
(
	default  => sub{return 15},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has uid =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has x_step =>
(
	default  => sub{return 50},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has y_step =>
(
	default  => sub{return 36},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

our $VERSION = '1.00';

# ------------------------------------------------

sub BUILD
{
	my($self) = @_;

	$self -> root($self -> new_node('0', {place => 'middle'}) );

} # End of BUILD.

# ------------------------------------------------

sub _calculate_basic_attributes
{
	my($self)	= @_;
	my($x_step)	= $self -> x_step;
	my($y_step)	= $self -> y_step;

	my($attributes);
	my($parent_attributes);
	my($scale);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node, $options)	= @_;
			$attributes			= $node -> attributes;

			# Set defaults if steps are not provided.

			$$attributes{x_step}	||= $x_step;
			$$attributes{y_step}	||= $y_step;

			# Set co-ords.

			if ($node -> is_root)
			{
				$$attributes{x}	= 0;
				$$attributes{y} = 0;
			}
			else
			{
				# $scale is a multiplier for the sister step.

				$scale				= $$attributes{place} eq 'above'
										? -1
										: $$attributes{place} eq 'middle'
											? 0
											: 1;
				$parent_attributes	= $node -> mother -> attributes;
				$$attributes{x}		= $$parent_attributes{x} + $$attributes{x_step};
				$$attributes{y}		= $$parent_attributes{y} + $scale * $$attributes{y_step};
			}

			$node -> attributes($attributes);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of _calculate_basic_attributes.

# ------------------------------------------------

sub _check_point_within_rectangle
{
	my($self, $bounds_1, $x, $y) = @_;
	my($result)	= 0;
	my($x_min)	= $$bounds_1[0];
	my($y_min)	= $$bounds_1[1];
	my($x_max)	= $$bounds_1[2];
	my($y_max)	= $$bounds_1[3];

	if ( ($x >= $x_min) && ($x <= $x_max)
		&&	($y >= $y_min) && ($y <= $y_max) )
	{
		$result = 1;
	}

	return $result;

} # End of _check_point_within_rectangle.

# ------------------------------------------------

sub _check_rectangle_within_rectangle
{
	my($self, $bounds_1, $bounds_2) = @_;
	my($result)		= 0;
	my($x_min_2)	= $$bounds_2[0];
	my($y_min_2)	= $$bounds_2[1];
	my($x_max_2)	= $$bounds_2[2];
	my($y_max_2)	= $$bounds_2[3];

	if ($self -> _check_point_within_rectangle($bounds_1, $x_min_2, $y_min_2)
		||	$self -> _check_point_within_rectangle($bounds_1, $x_max_2, $y_min_2)
		||	$self -> _check_point_within_rectangle($bounds_1, $x_min_2, $y_max_2)
		||	$self -> _check_point_within_rectangle($bounds_1, $x_max_2, $y_max_2) )
	{
		$result = 1;
	}

	return $result;

} # End of _check_rectangle_within_rectangle.

# ------------------------------------------------

sub _check_node_bounds
{
	my($self, $node_1)	= @_;
	my($leaf_font_size)	= $self -> leaf_font_size;
	my($attributes_1)	= $node_1 -> attributes;
	my($bounds_1)		= $$attributes_1{bounds};
	my($uid_1)			= $$attributes_1{uid};

	my($attributes_2);
	my($bounds_2);
	my($candidate_step);
	my($parent_attributes);
	my($uid_2);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node_2)		= @_;
			$attributes_2	= $node_2 -> attributes;
			$bounds_2		= $$attributes_2{bounds};
			$uid_2			= $$attributes_2{uid};

			if ($uid_1 < $uid_2)
			{
				if ($self -> _check_rectangle_within_rectangle($bounds_1, $bounds_2) )
				{
					# Move the node down to avoid the overlap.
					# This assumes it's an 'above' node.
					# The formula for $candidate_step is my own invention,
					# selected after many experiments.

					$candidate_step			= int($leaf_font_size / 2) + 8;
					$$bounds_2[1]			+= $candidate_step;
					$$bounds_2[3]			+= $candidate_step;
					$$attributes_2{bounds}	= $bounds_2;
					$$attributes_2{y}		+= $candidate_step;

					$node_2 -> attributes($attributes_2);
				}
			}

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of _check_node_bounds.

# ------------------------------------------------

sub _check_for_overlap
{
	my($self) = @_;

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node) = @_;

			$self -> _check_node_bounds($node);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of _check_for_overlap.

# ------------------------------------------------

sub draw_image
{
	my($self)			= @_;
	my($final_x_step)	= $self -> final_x_step;
	my($maximum_x)		= $self -> maximum_x + $self -> left_margin;
	my($maximum_y)		= $self -> maximum_y + $self -> top_margin;
	my($image)			= $self -> create_image($maximum_x, $maximum_y);
	my($x_step)			= $self -> x_step;

	my($attributes);
	my(@daughters, @daughter_attributes, $daughter_attributes);
	my(@final_daughters, $final_offset);
	my($index);
	my($middle_attributes);
	my($name);
	my($place, %place);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			@daughters	= $node -> daughters;
			%place		= ();

			for (0 .. $#daughters)
			{
				$daughter_attributes[$_]	= $daughters[$_] -> attributes;
				$place						= $daughter_attributes[$_]{place};
				$place{$place}				= $_;
				$middle_attributes			= $daughter_attributes[$_] if ($place eq 'middle');
			}

			# Connect above and below daughters to middle daughter.

			for $place (keys %place)
			{
				$index					= $place{$place};
				$name					= $daughters[$index] -> name;
				$daughter_attributes	= $daughter_attributes[$index];

				$self -> draw_vertical_branch($image, $middle_attributes, $daughter_attributes);

				if ( ($node -> name ne $name) && ($name ne 'root') )
				{
					# Stretch the horizontal lines, but only for leaves.

					@final_daughters	= $daughters[$index] -> daughters;
					$final_offset		= $#final_daughters < 0 ? $final_x_step : 0;

					$self -> draw_horizontal_branch($image, $middle_attributes, $daughter_attributes, $final_offset);
					$self -> draw_leaf_name($image, $name, $daughter_attributes, $final_offset);

				}
			}

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	# Draw a line off to the left of the middle daughter of the root.

	$self -> draw_root_branch($image);
	$self -> draw_title($image, $maximum_x, $maximum_y);

	my($output_file) = $self -> output_file;

	if (length($output_file) )
	{
		$image -> write(file => $output_file);
		$self -> log('Wrote ' . $output_file);
	}

} # End of draw_image.

# ------------------------------------------------

sub find_maximum_x
{
	my($self)		= @_;
	my($maximum_x)	= 0;

	my($attributes);
	my($bounds);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			$bounds		= $$attributes{bounds};
			$maximum_x	= $$bounds[2] if ($$bounds[2] > $maximum_x);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$maximum_x += $self -> final_x_step;
	$maximum_x = $self -> title_width if ($self -> title_width > $maximum_x);

	$self -> maximum_x($maximum_x);

} # End of find_maximum_x.

# ------------------------------------------------

sub find_maximum_y
{
	my($self)		= @_;
	my($maximum_y)	= 0;

	my($attributes);
	my($bounds);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			$bounds		= $$attributes{bounds};
			$maximum_y	= $$bounds[3] if ($$bounds[3] > $maximum_y);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$self -> maximum_y($maximum_y);

} # End of find_maximum_y.

# ------------------------------------------------

sub find_minimum_y
{
	my($self)		= @_;
	my($minimum_y)	= 0;

	my($attributes);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			$minimum_y	= $$attributes{y} if ($$attributes{y} < $minimum_y);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$self -> minimum_y($minimum_y);

} # End of find_minimum_y.

# ------------------------------------------------

sub log
{
	my($self, $message) = @_;

	print "$message\n";

} # End of log.

# ------------------------------------------------

sub move_away_from_frame
{
	my($self)		= @_;
	my($minimum_y)	= $self -> minimum_y;
	my($top_margin)	= $self -> top_margin;
	my($x_offset)	= $self -> left_margin;
	my($y_offset)	= $minimum_y <= 0
						? $top_margin - $minimum_y
						: $minimum_y < $top_margin
							? $top_margin - $minimum_y
							: - $minimum_y + $top_margin;

	my($attributes);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)		= @_;
			$attributes		= $node -> attributes;
			$$attributes{x}	+= $x_offset;
			$$attributes{y}	+= $y_offset;

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$self -> minimum_y($minimum_y);

} # End of move_away_from_frame.

# ------------------------------------------------

sub new_node
{
	my($self, $name, $attributes)  = @_;
	$$attributes{bounds}	= [];
	$$attributes{uid}		= $self -> uid($self -> uid + 1);

	return Tree::DAG_Node -> new({name => $name, attributes => $attributes});

} # End of new_node.

# ------------------------------------------------

sub read
{
	my($self)	= @_;
	my($count)	= 0;
	my($parent)	= $self -> root;

	my(%cache);
	my(@field);
	my($node);
	my(%seen);

	for my $line (read_lines($self -> input_file) )
	{
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		next if ( (length($line) == 0) || ($line =~ /^\s*#/) );

		$count++;

		# Format expected (see data/wikipedia.01.clad):
		#
		# Parent	Place	Node
		# Root		above	Beetles
		# Root		below	1
		# 1			above	Wasps, bees, ants
		# 1			below	2
		# 2			above	Butterflies, moths
		# 2			below	Flies

		@field		= split(/\s+/, $line, 3);
		$field[$_]	= lc $field[$_] for (0 .. 1);

		if ($count == 1)
		{
			$field[2] = lc $field[2];

			if ( ($field[0] ne 'parent') || ($field[1] ne 'place') || ($field[2] ne 'node') )
			{
				die "Error. Input file line $count is in the wrong format. It must be 'Parent Place Node'\n";
			}

			next;
		}

		if ($#field <= 1)
		{
			die "Error. Input file line $count does not have enough columns\n";
		}

		# Count the # of times each node appears. This serves several purposes.

		$seen{$field[0]} = 0 if (! defined $seen{$field[0]});
		$seen{$field[0]}++;

		if ($seen{$field[0]} > 2)
		{
			die "Error. Input file line $count has $seen{$field[0]} copies of $field[0], but the maximum must be 2\n";
		}
		elsif ($field[1] !~ /above|below/)
		{
			die "Error. Input file line $count has a unknown place: '$field[1]'. It must be 'above' or 'below'\n";
		}

		# The first time each node appears, give its parent a middle daughter.
		# Note: The node called 'root' is not cached.

		if ($seen{$field[0]} == 1)
		{
			$node = $self -> new_node($field[0], {place => 'middle'});

			if ($cache{$field[0]})
			{
				$parent	= $cache{$field[0]};

				$parent -> add_daughter($node);
			}
			else
			{
				$parent -> add_daughter($node);
			}
		}

		# Now give the middle daughter its above and below sisters, one each time thru the loop.

		$cache{$field[2]} = $self -> new_node($field[2], {place => $field[1]});

		$parent -> add_daughter($cache{$field[2]});
	}

} # End of read.

# ------------------------------------------------

sub run
{
	my($self) = @_;

	$self -> read;
	$self -> _calculate_basic_attributes;
	$self -> find_minimum_y;
	$self -> move_away_from_frame if ($self -> minimum_y <= $self -> top_margin);
	$self -> _calculate_leaf_name_bounds;
	$self -> _check_for_overlap;
	$self -> find_maximum_x;
	$self -> find_maximum_y;
#	$self -> draw_image;

	$self -> log(join('', map("$_\n", @{$self -> root -> tree2string}) ) ) if ($self -> print_tree);

	# Return 0 for success and 1 for failure.

	return 0;

} # End of run.

# ------------------------------------------------

1;

=pod

=head1 NAME

C<Tree::Cladogram> - Render a tree as a cladogram

=head1 Synopsis

This is scripts/plot.pl:

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
		'title_font_size=s',
	) )
	{
		pod2usage(1) if ($option{'help'});

		exit Tree::Cladogram -> new(%option) -> run;
	}
	else
	{
		pod2usage(2);
	}

As you can see, you create an object and then call L</run()>.

And this is the heart of scripts/plot.sh:

	perl -Ilib scripts/plot.pl \
		-draw_frame $FRAME \
		-input_file data/$i.01.clad \
		-leaf_font_file $LEAF_FONT_FILE \
		-output_file data/$i.01.png \
		-title "$TITLE" \
		-title_font_file $TITLE_FONT_FILE \

=head1 Description

L<Tree::Cladogram> provides a mechanism to turn a tree into a cladogram image.
The image of generated using L<Imager>. The input is read from a text file.

For information about cladograms, see L<https://en.wikipedia.org/wiki/Cladogram>.

For another sample of a cladogram, see
L<http://phenomena.nationalgeographic.com/2015/12/11/paleo-profile-the-smoke-hill-bird/>.

Sample input is shipped as data/*.clad.

Sample output is shipped as data/*.png:

L<http://savage.net.au/misc/wikipedia.01.png>

L<http://savage.net.au/misc/nationalgeographic.01.png>

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See L<http://savage.net.au/Perl-modules/html/installing-a-module.html>
for help on unpacking and installing distros.

=head1 Installation

Install L<Tree::Cladogram> as you would for any C<Perl> module:

Run:

	cpanm Tree::Cladogram

or run:

	sudo cpan Tree::Cladogram

or unpack the distro, and then:

	perl Makefile.PL
	make (or dmake or nmake)
	make test
	make install

=head1 Constructor and Initialization

C<new()> is called as C<< my($cladtronic) = Tree::Cladogram -> new(k1 => v1, k2 => v2, ...) >>.

It returns a new object of type C<Tree::Cladogram>.

Key-value pairs accepted in the parameter list (see corresponding methods for details
[e.g. L</branch_color([$string])>]):

=over 4

=item o branch_color => $string

Specify the color of the branches in the tree.

Default: '#7e7e7e' (gray).

=item o branch_width => $integer

Specify the thickness of the branches.

Default: 3 (px).

=item o draw_frame => $Boolean

Specify that you want a frame around the image.

Default: 0 (no frame).

=item o final_x_step => $integer

Specify the length of the final branch leading to the names of the leaves.

Default: 30 (px).

=item o frame_color => $string

Specify the color of the frame, if any.

See also C<draw_frame>.

Default: '#0000ff' (blue).

=item o input_file => $string

Specify the name of the *.clad file to read. Of course, the suffix does not have to be 'clad'.

The format of this file is specified in the L<FAQ>.

Default: ''.

=item o leaf_font_color => $string

Specify the font color of the name of each leaf.

Default: '#0000ff' (blue).

=item o leaf_font_file => $string

Specify the name of the font file to use for the names of the leaves.

Default: '/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf'.

=item o leaf_font_size => $integer

Specify the size of the text used for the name of each leaf.

Default: 16 (points).

=item o left_margin => $integer

Specify the distance from the left of the image to the left-most point at which something is drawn.

Default: 15 (px).

=item o output_file => $string

Specify the name of the image file to write.

Image formats supported are anything supported by L<Imager>. See the L<FAQ> for more.

Default: '' (no output).

=item o print_tree => $Boolean

Specify that you want to print the tree constructed by the code.

This option is really a debugging aid.

Default: 0 (no tree).

=item o title => $string

Specify the title to draw at the bottom of the image.

Default: '' (no title).

=item o title_font_color => $string

Specify the font color of the name of each leaf.

Default: '#000000' (black).

=item o title_font_file => $string

Specify the name of the font file to use for the names of the leaves.

Default: '/usr/share/fonts/truetype/freefont/FreeSansBold.ttf'.

=item o leaf_font_size => $integer

Specify the size of the text used for the name of each leaf.

Default: 16 (points).

=item o top_margin => $integer

Specify the distance from the top of the image to the top-most point at which something is drawn.

Default: 15 (px).

=item o x_step => $integer

The horizontal length of branches.

See also C<final_x_step> and C<y_step>.

Default: 50 (px).

=item o y_step => $integer

The vertical length of the branches.

Note: Some vertical branches will be shortened if the code detects overlapping when leaf names are
drawn.

See also C<x_step>.

Default: 40 (px).

=back

=head1 Methods

=head2 branch_color([$string])

Get or set the color used to fraw branches.

C<branch_color> is a parameter to L</new()>.

=head2 branch_width([$integer])

Get or set the width of branches.

C<branch_width> is a parameter to L</new()>.

=head2 draw_frame([$Boolean])

Get or set the option to draw a frame on the image.

C<draw_frame> is a parameter to L</new()>.

=head2 final_x_step([$integer])

Get or set the horizontal length of the branch leading to leaf names.

C<final_x_step> is a parameter to L</new()>.

=head2 frame_color([$string])

Get or set the color of the frame.

C<frame_color> is a parameter to L</new()>.

=head2 input_file([$string])

Get or set the name of the input file.

C<input_file> is a parameter to L</new()>.

=head2 leaf_font_color([$string])

Get or set the font color of the text used to draw leaf names.

C<leaf_font_color> is a parameter to L</new()>.

=head2 leaf_font_file([$string])

Get or set the name of the font file used for leaf names.

C<leaf_font_file> is a parameter to L</new()>.

=head2 leaf_font_size([$integer])

Get or set the size of the font used to draw leaf names.

C<leaf_font_size> is a parameter to L</new()>.

=head2 left_margin([$integer])

Get or set the distance from the left edge at which drawing starts.

This also sets the right margin.

C<left_margin> is a parameter to L</new()>.

=head2 maximum_x()

Get the right-most point at which something was drawn.

This value is determined by examining the bounding boxes of all leaf names.

=head2 maximum_y()

Get the bottom-most point at which something was drawn.

=head2 new()

See L</Constructor and Initialization> for details on the parameters accepted by L</new()>.

=head2 output_file([$string])

Get or set the name of the output file.

The file suffix determines what type of file is written.

For more on supported image types, see the L<FAQ>.

C<output_file> is a parameter to L</new()>.

=head2 print_tree([$Boolean])

Get or set the option to print the tree constructed by the code. This is basically a debugging
option.

C<print_tree> is a parameter to L</new()>.

=head2 root()

Get the root of the tree built by calling run(). This tree is an object of type L<Tree::DAG_Node>.

For printing the tree, see L</print_tree([$Boolean])>.

Normally, end-users would never call this method.

=head2 run()

After calling L</new()>, this is the only other method you would normally call.

=head2 title([$string])

Get or set the title to be drawn at the bottom of the image.

Note: It's vital you set the title before calling L</run()>, since the width of the title might
be greater that the width of the tree, and the width of the title would then be used to determine
the width of the image to create.

C<title> is a parameter to L</new()>.

=head2 title_font_color([$string])

Get or set the font color of the text used to draw the title.

C<title_font_color> is a parameter to L</new()>.

=head2 title_font_file([$string])

Get or set the name of the font file used for the title.

C<title_font_file> is a parameter to L</new()>.

=head2 title_font_size([$integer])

Get or set the size of the font used to draw the title.

C<title_font_size> is a parameter to L</new()>.

=head2 top_margin([$integer])

Get or set the distance from the top edge at which drawing starts.

This also sets the bottom margin.

C<top_margin> is a parameter to L</new()>.

=head2 x_step([$integer])

Get or set the length of horizontal branches.

See also C<final_x_step>.

C<x_step> is a parameter to L</new()>.

=head2 y_step([$integer])

Get or set the length of vertical branches.

Note: Some vertical branches will be shortened if the code detects overlapping when leaf names are
drawn.

C<y_step> is a parameter to L</new()>.

=head1 FAQ

=head2 What is the format of the input file?

Sample 1 - L<https://en.wikipedia.org/wiki/Cladogram>:

	        +---- Beetles
	        |
	        |
	Root ---+	+---- Wasps, bees, ants
	        |	|
	        |	|
	        1---+	+---- Butterflies, moths
	            |	|
	            |	|
	            2---+
	                |
	                |
	                +---- Flies

This is the data file (shipped as data/cladogram.01.clad). The format is defined below:

	Parent  Place  Node
	root    above  Beetles
	root    below  1
	1       above  Wasps, bees, ants
	1       below  2
	2       above  Butterflies, moths
	2       below  Flies

Output: L<http://savage.net.au/misc/wikipedia.01.png>.

Sample 2 - L<http://phenomena.nationalgeographic.com/2015/12/11/paleo-profile-the-smoke-hill-bird/>:

	        +--- Archaeopterix lithographica
	        |
	        |
	        |
	Root ---+   +--- Apsaravis ukhaana
	        |   |
	        |   |
	        |   |
	        1---+   +--- Gansus yumemensis
	            |   |
	            |   |
	            |   |
	            2---+   +--- Ichthyornis dispar
	                |   |
	                |   |       +--- Gallus gallus
	                |   |       |
	                3---+   5---+
	                    |   |   |
	                    |   |   +--- Anas clypeata
	                    |   |
	                    4---+
	                        |   +--- Pasquiaornis
	                        |   |
	                        |   |
	                        6---+   +--- Enaliornis
	                            |   |
	                            |   |
	                            |   |
	                            7---+   +--- Baptornis advenus
	                                |   |
	                                |   |       +--- Brodavis varnei
	                                |   |       |
	                                8---+   10--+
	                                    |   |   |
	                                    |   |   +--- Brodavis baileyi
	                                    |   |
	                                    9---+
	                                        |   +--- Fumicollis hoffmani
	                                        |   |
	                                        |   |
	                                        11--+   +--- Parahesperornis alexi
	                                            |   |
	                                            |   |
	                                            12--+
	                                                |
	                                                |
	                                                +--- Hesperornis regalis

This is the data file (shipped as  data/nationalgeographic.01.clad). The format is defined below:

	Parent  Place  Node
	root    above  Archaeopterix lithographica
	root    below  1
	1       above  Apsaravis ukhaana
	1       below  2
	2       above  Gansus yumemensis
	2       below  3
	3       above  Ichthyornis dispar
	3       below  4
	4       above  5
	4       below  6
	5       above  Gallus gallus
	5       below  Anas clypeata
	6       above  Pasquiaornis
	6       below  7
	7       above  Enaliornis
	7       below  8
	8       above  Baptornis advenus
	8       below  9
	9       above  10
	9       below  11
	10      above  Brodavis varnei
	10      below  Brodavis baileyi
	11      above  Fumicollis hoffmani
	11      below  12
	12      above  Parahesperornis alexi
	12      below  Hesperornis regalis

Output: L<http://savage.net.au/misc/nationalgeographic.01.png>.

File format:

=over 4

=item o All lines are tab separated

=item o There are 3 columns

=over 4

=item o The first line must match /Parent\tPlace\tNode/i

=item o Column 1 is the name of the node

Notice how every node has 2 mandatory lines.

=item o The word 'root' is (also) case-insensitive

=item o Column 2 specifies where the daughter appears in relation to the node

=item o All words after the 2nd column are the name of that daughter

=back

=item o Fabricate skeleton nodes to hold together the nodes you are interested in

=item o Use digits for the fake node names

The code hides the name of nodes which match /^(\d+|root)$/.

=back

=head2 What image formats are supported?

My default install of L<Imager> lists:

	bmp
	ft2
	ifs
	png
	pnm
	raw

=head2 What font formats are supported?

Check these directories:

=over

=item o /usr/local/share/fonts

=item o /usr/share/fonts

=back

If you're using L<Debian|http://debian.org>, run C<fc-list> for a list of installed fonts.

More information on Debian's support for fonts can be found on Debian's
L<wiki|https://wiki.debian.org/Fonts>.

See scripts/imager.sh for a list of fonts I have played with while developing this module.

Further, note this text copied from the docs for L<Imager::Font>:

	This module handles creating Font objects used by Imager. The module also handles querying
	fonts for sizes and such. If both T1lib and FreeType were available at the time of compilation
	then Imager should be able to work with both TrueType fonts and t1 Postscript fonts. To check
	if Imager is t1 or TrueType capable you can use something like this:

	use Imager;

	print "Has truetype\n"      if $Imager::formats{tt};
	print "Has t1 postscript\n" if $Imager::formats{t1};
	print "Has Win32 fonts\n"   if $Imager::formats{w32};
	print "Has Freetype2\n"     if $Imager::formats{ft2};

My default install of L<Imager> reports:

	Has Freetype2

=head2 How does leaf_font_size interact with y_step?

This might depend on the font, but here are some tests I ran with the default leaf font:

=over 4

=item o leaf_font_size 12 works with y_step values of 28 .. 40

=item o leaf_font_size 16 works with y_step values of 36 .. 44

=item o leaf_font_size 20 works with y_step values of 40 .. 48

=item o leaf_font_size 24 works with a y_step value of 48

=item o leaf_font_size 28 works with a y_step value of 54

=item o leaf_font_size 32 works with a y_step value of 54

=item o leaf_font_size 36 works with a y_step value of 72

=item o leaf_font_size 40 works with a y_step value of 72

=back

=head2 How is overlap between leaves detected?

The process starts by calling the undocumented method C<_check_for_overlap()>.

=head1 See Also

L<Imager>

L<Tree::DAG_Node>

=head1 TODO

=over 4

=item o Create 2 sub-classes, to support L<Imager> and L<Image::Magick>

=item o In _check_node_bounds(), could there be cases when nodes should be moved up?

=back

=head1 Machine-Readable Change Log

The file Changes was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 Repository

L<https://github.com/ronsavage/Tree-Cladogram>

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Tree::Cladogram>.

=head1 Author

L<Tree::Cladogram> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2015.

My homepage: L<http://savage.net.au/>

=head1 Copyright

Australian copyright (c) 2015, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License 2.0, a copy of which is available at:
	http://opensource.org/licenses/alphabetical.

=cut
