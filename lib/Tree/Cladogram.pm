package Tree::Cladogram;

use File::Slurper 'read_lines';

use Imager;
use Imager::Fill;

use Moo;

use Tree::DAG_Node;

use Types::Standard qw/Any Int Str/;

has child_step =>
(
	default  => sub{return 50},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has font_file =>
(
	default  => sub{return '/usr/local/share/fonts/truetype/gothic.ttf'},
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

has sister_step =>
(
	default  => sub{return 30},
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

our $VERSION = '1.00';

# ------------------------------------------------

sub compute_co_ords
{
	my($self)			= @_;
	my($child_step)		= $self -> child_step;
	my($sister_step)	= $self -> sister_step;

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

			$$attributes{child_step}	||= $child_step;
			$$attributes{sister_step}	||= $sister_step;

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
				$$attributes{x}		= $$parent_attributes{x} + $$attributes{child_step};
				$$attributes{y}		= $$parent_attributes{y} + $scale * $$attributes{sister_step};
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
	my($self)		= @_;
	my($maximum_x)	= 0;

	$self -> maximum_x($self -> child_step * $self -> root -> depth_under);

} # End of find_maximum_x.

# ------------------------------------------------

sub find_maximum_y
{
	my($self)		= @_;
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

sub plot_image
{
	my($self)		= @_;
	my($maximum_x)	= $self -> maximum_x + 500;
	my($maximum_y)	= $self -> maximum_y + 100;
	my($image)		= Imager -> new(xsize => $maximum_x, ysize => $maximum_y);
	my($grey)		= Imager::Color -> new(0x80, 0x80, 0x80);
	my($blue)		= Imager::Color -> new(0, 0, 255);
	my($white)		= Imager::Color -> new(255, 255, 255);
	my($font_size)	= 8; # TODO: Explain why next line uses 2 * 8.
	my($font)		= Imager::Font -> new(color => $blue, file => $self -> font_file, size => 2 * $font_size) || die "Error. Can't define font: " . Imager -> errstr;
	my($x_step)		= $self -> child_step;

	$image -> box(color => $white, filled => 1);
	$image -> box(color => $blue);

	my($attributes);
	my(@daughters, @daughter_attributes, $daughter_attributes);
	my($index);
	my($middle_attributes);
	my($name);
	my($parent_attributes, $place, %place);

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
				$daughter_attributes	= $daughter_attributes[$index];
				$name					= $daughters[$index] -> name;

				# Draw a line (a filled box) up or down from the middle,
				# and then draw a line from there off to the right.

				$image -> box
				(
					box =>
					[
						$$middle_attributes{x},
						$$middle_attributes{y},
						$$middle_attributes{x} + 2,
						$$daughter_attributes{y},
					],
					color	=> $grey,
					filled	=> 1,
				);

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

				if (length($name) > 0)
				{
					$image -> string
					(
						font	=> $font,
						string	=> $name,
						x		=> $$daughter_attributes{x} + $x_step + 4,
						y		=> $$daughter_attributes{y} + $font_size,
					);
				}
			}

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

=pod

				# Draw a line off to the left of the middle daughter of the root.

				if ($node -> is_root)
				{
					$image -> box
					(
						box =>
						[
							$$middle_attributes{x},
							$$middle_attributes{y},
							$$middle_attributes{x} - $x_step + 1,
							$$middle_attributes{y} + 2,
						],
						color	=> $grey,
						filled	=> 1,
					);
				}

=cut

	$image -> write(file => $self -> output_file);

} # End of plot_image.

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

=pod

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

Parent	Place	Node
root	Above	Beetles
root	Below	1
1		Above	Wasps, bees, ants
1		Below	2
2		Above	Butterflies, moths
2		Below	Flies

=cut

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

	$self -> read;
	$self -> compute_co_ords;
	$self -> find_maximum_x;
	$self -> find_minimum_y;

	print 'maximum_x:  ', $self -> maximum_x, "\n";
	print 'minimum_y:  ', $self -> minimum_y, "\n";
	print 'top_margin: ', $self -> top_margin, "\n";

	$self -> shift_image if ($self -> minimum_y <= $self -> top_margin);
	$self -> find_maximum_y;

	print 'maximum_y:  ', $self -> maximum_y, "\n";
	print map("$_\n", @{$self -> root -> tree2string({no_attributes => 0})}), "\n";

	$self -> plot_image;

} # End of run.

# ------------------------------------------------

sub shift_image
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
