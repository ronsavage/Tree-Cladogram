package Tree::Cladogram;

use File::Slurper 'read_lines';

use Imager;
use Imager::Fill;

use Moo;

use Tree::DAG_Node;

use Types::Standard qw/Any ArrayRef Int Str/;

has font =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has font_color =>
(
	default  => sub{return [0, 0, 255]},
	is       => 'rw',
	isa      => ArrayRef,
	required => 0,
);

has font_file =>
(
	default  => sub{return '/usr/local/share/fonts/truetype/gothic.ttf'},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has font_size =>
(
	default  => sub{return 16},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has image =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has input_file =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Str,
	required => 0,
);

has left_margin =>
(
	default  => sub{return 5},
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

has root =>
(
	default  => sub{return Tree::DAG_Node -> new({name => 'omni', attributes => {place => 'omni'} })},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has top_margin =>
(
	default  => sub{return 15},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has verbose =>
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
	default  => sub{return 30},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

our $VERSION = '1.00';

# ------------------------------------------------

sub BUILD
{
	my($self)	= @_;
	my($color)	= Imager::Color -> new(@{$self -> font_color});

	$self -> font
	(
		Imager::Font -> new
		(
			color	=> $color,
			file	=> $self -> font_file,
			size	=> $self -> font_size,
			utf8	=> 1
		) || die "Error. Can't define font: " . Imager -> errstr
	);

	$self -> image(Imager -> new);

} # End of BUILD.

# ------------------------------------------------

sub compute_co_ords
{
	my($self) = @_;

	$self -> log('Entered compute_co_ords()');

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

} # End of compute_co_ords.

# ------------------------------------------------

sub find_maximum_x
{
	my($self) = @_;

	$self -> log('Entered find_maximum_x()');

	$self -> maximum_x($self -> x_step * $self -> root -> depth_under);

} # End of find_maximum_x.

# ------------------------------------------------

sub find_maximum_y
{
	my($self) = @_;

	$self -> log('Entered find_maximum_y()');

	my($maximum_y)	= 0;

	my($attributes);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			$maximum_y	= $$attributes{y} if ($$attributes{y} > $maximum_y);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$self -> maximum_y($maximum_y);

} # End of find_maximum_y.

# ------------------------------------------------

sub find_minimum_y
{
	my($self) = @_;

	$self -> log('Entered find_minimum_y()');

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

	print "$message. \n" if ($self -> verbose);

} # End of log.

# ------------------------------------------------

sub place_text
{
	my($self) = @_;

	$self -> log('Entered place_text()');

	my($font_size)	= $self -> font_size;
	my($x_step)		= $self -> x_step;

	my($attributes);
	my(@bounds);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			@bounds		= $self -> image
							(
								halign	=> 'left',
								image	=> undef,		# Don't draw on the image.
								string	=> $node -> name,
								valign	=> 'baseline',	# The default.
								x		=> $$attributes{x} + $x_step + 4,
								y		=> $$attributes{y} + $font_size,
							);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of place_text.

# ------------------------------------------------

sub plot_image
{
	my($self) = @_;

	$self -> log('Entered plot_image()');

	my($maximum_x)	= $self -> maximum_x + 500;
	my($maximum_y)	= $self -> maximum_y + 100;
	my($image)		= Imager -> new;
	my($fuschia)	= Imager::Color -> new(0xff, 0, 0xff);
	my($grey)		= Imager::Color -> new(0x80, 0x80, 0x80);
	my($blue)		= Imager::Color -> new(0, 0, 255);
	my($white)		= Imager::Color -> new(255, 255, 255);
	my($font_size)	= 8; # TODO: Explain why next line uses 2 * 8.
	my($x_step)		= $self -> x_step;

	$image -> box(color => $white, filled => 1);
	$image -> box(color => $blue);

	my($attributes);
	my($box_object);
	my(@daughters, @daughter_attributes, $daughter_attributes);
	my($index);
	my($middle_attributes);
	my($name);
	my($parent_attributes, $place, %place);
	my($x);
	my($y);

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
				$daughter_attributes[$_]	= $daughter_attributes = $daughters[$_] -> attributes;
				$place						= $$daughter_attributes{place};
				$place{$place}				= $_;
				$middle_attributes			= $daughter_attributes if ($place eq 'middle');
			}

			# Connect above and below daughters to middle daughter.

			for $place (keys %place)
			{
				$index					= $place{$place};
				$name					= $daughters[$index] -> name;
				$daughter_attributes	= $daughter_attributes[$index];

				# 1: Draw a line (a filled box) up or down from the middle.

				$image -> box
				(
					box =>
					[
						$$middle_attributes{x},
						$$middle_attributes{y},
						$$middle_attributes{x} + 2,
						$$daughter_attributes{y},
					],
					color	=> $fuschia,
					filled	=> 1,
				);

				if ( ($node -> name ne $name) && ($name ne 'root') )
				{
					# 2: Draw a line from there off to the right.

					$image -> box
					(
						box =>
						[
							$$middle_attributes{x},
							$$daughter_attributes{y},
							$$daughter_attributes{x} + $x_step,
							$$daughter_attributes{y} + 2,
						],
						color	=> $grey,
						filled	=> 1,
					);

					# 3: Draw the text.

=pod

					if ( (length($name) > 0) && ($name !~ /^\d+$/) )
					{
						$x	= $$daughter_attributes{x} + $x_step + 4;
						$y	= $$daughter_attributes{y} + $font_size;

						$box_object = $self -> font -> bounding_box
						(
							string	=> $name,
							x		=> $x,
							y		=> $y,
						);

						print "Print. name: $name \@ ($x, $y). display_width: ", $box_object -> display_width, ". \n";

						$image -> string
						(
							font	=> $self -> font,
							string	=> $name,
							x		=> $x,
							y		=> $y,
						);
					}

=cut

				}
			}

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	# Draw a line off to the left of the middle daughter of the root.

	$attributes				= $self -> root -> attributes;
	@daughters				= $self -> root -> daughters;
	$daughter_attributes	= $daughters[0] -> attributes;

	$image -> box
	(
		box =>
		[
			$$daughter_attributes{x},
			$$daughter_attributes{y},
			$$attributes{x} - $x_step + 1,
			$$attributes{y} + 2,
		],
		color	=> $grey,
		filled	=> 1,
	);

	$image -> write(file => $self -> output_file);

} # End of plot_image.

# ------------------------------------------------

sub read
{
	my($self) = @_;

	$self -> log('Entered read()');

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
			$node = Tree::DAG_Node -> new({name => $field[0], attributes => {place => 'middle'} });

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

		$cache{$field[2]} = Tree::DAG_Node -> new({name => $field[2], attributes => {place => $field[1]} });

		$parent -> add_daughter($cache{$field[2]});
	}

} # End of read.

# ------------------------------------------------

sub run
{
	my($self) = @_;

	$self -> log('Entered run()');

	$self -> read;
	$self -> compute_co_ords;
	$self -> find_maximum_x;
	$self -> find_minimum_y;
	$self -> shift_image if ($self -> minimum_y <= $self -> top_margin);
	$self -> place_text;
	$self -> find_maximum_y;
	$self -> plot_image;

	$self -> log('Leaving run()');

	# Return 0 for success and 1 for failure.

	return 0;

} # End of run.

# ------------------------------------------------

sub shift_image
{
	my($self) = @_;

	$self -> log('Entered shift_image()');

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

} # End of shift_image.

# ------------------------------------------------

1;

=pod

	Sample 1:

	See L<https://en.wikipedia.org/wiki/Cladogram>

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


	For matching data file, see data/cladogram.01.txt

	Parent	Place	Node
	root	above	Beetles
	root	below	1
	1		above	Wasps, bees, ants
	1		below	2
	2		above	Butterflies, moths
	2		below	Flies

	Sample 2:

	See L<http://phenomena.nationalgeographic.com/2015/12/11/paleo-profile-the-smoke-hill-bird/>

			+--- Archaeopterix lithographica
			|
			|
			|
	Root ---+	+--- Apsaravis ukhaana
			|	|
			|	|
			|	|
			1---+	+--- Gansus yumemensis
				|	|
				|	|
				|	|
				2---+	+--- Ichthyornis dispar
					|	|
					|	|		+--- Gallus gallus
					|	|		|
					3---+	5---+
						|	|	|
						|	|	+--- Anas clypeata
						|	|
						4---+
							|	+--- Pasquiaornis
							|	|
							|	|
							6---+	+--- Enaliornis
								|	|
								|	|
								|	|
								7---+	+--- Baptornis advenus
									|	|
									|	|		+--- Brodavis varnei
									|	|		|
									8---+	10--+
										|	|	|
										|	|	+--- Brodavis baileyi
										|	|
										9---+
											|	+--- Fumicollis hoffmani
											|	|
											|	|
											11--+	+--- Parahesperornis alexi
												|	|
												|	|
												12--+
													|
													|
													+--- Hesperornis regalis

	For matching data file, see data/nationalgeographic.01.clad

	Parent	Place	Node
	root	above	Archaeopterix lithographica
	root	below	1
	1		above	Apsaravis ukhaana
	1		below	2
	2		above	Gansus yumemensis
	2		below	3
	3		above	Ichthyornis dispar
	3		below	4
	4		above	5
	4		below	6
	5		above	Gallus gallus
	5		below	Anas clypeata
	6		above	Pasquiaornis
	6		below	7
	7		above	Enaliornis
	7		below	8
	8		above	Baptornis advenus
	8		below	9
	9		above	10
	9		below	11
	10		above	Brodavis varnei
	10		below	Brodavis baileyi
	11		above	Fumicollis hoffmani
	11		below	12
	12		above	Parahesperornis alexi
	12		below	Hesperornis regalis


=cut
