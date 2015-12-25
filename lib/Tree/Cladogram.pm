package Tree::Cladogram;

use File::Slurper 'read_lines';

use Imager;

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
	default  => sub{return Tree::DAG_Node -> new({name => 'Root', attributes => {place => 'middle'} })},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has sister_step =>
(
	default  => sub{return 20},
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

	$self -> maximum_x($self -> left_margin + $self -> child_step * $self -> root -> depth_under);

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
	my($blue)		= Imager::Color -> new(0, 0, 255);
	my($red)		= Imager::Color -> new(255, 0, 0);
	my($white)		= Imager::Color -> new(255, 255, 255);
	my($x_step)		= $self -> child_step;

	$image -> box(color => $white, filled => 1);
	$image -> box(color => $blue);

	my($attributes);
	my(@daughters, @daughter_attributes, $daughter_attributes);
	my($middle_attributes);
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
				$daughter_attributes = $daughter_attributes[$place{$place}];

				if ($place eq 'middle')
				{
					# Draw a line off to the left of the middle daughter of the root.

					if ($node -> is_root)
					{
						$image -> line
						(
							aa		=> 1, # Anti-aliased.
							color	=> $blue,
							x1		=> $$middle_attributes{x},
							y1		=> $$middle_attributes{y},
							x2		=> $$middle_attributes{x} - $x_step,
							y2		=> $$middle_attributes{y},
						);
					}
				}
				else
				{
					$image -> line
					(
						aa		=> 1, # Anti-aliased.
						color	=> $blue,
						x1		=> $$middle_attributes{x},
						y1		=> $$middle_attributes{y},
						x2		=> $$daughter_attributes{x},
						y2		=> $$daughter_attributes{y},
					);
					$image -> line
					(
						aa		=> 1, # Anti-aliased.
						color	=> $blue,
						x1		=> $$daughter_attributes{x},
						y1		=> $$daughter_attributes{y},
						x2		=> $$daughter_attributes{x} + $x_step,
						y2		=> $$daughter_attributes{y},
					);
				}
			}

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$image -> write(file => $self -> output_file);

} # End of plot_image.

# ------------------------------------------------

sub read
{
	my($self)	= @_;
	my($count)	= 0;

	my(@fields);

	for my $line (map{/^[^#]/; $_} read_lines($self -> input_file) )
	{
		$count++;

		@fields = split(/\s+/, $line);

		# Format expected (see data/wikipedia.01.clad):
		#
		# Parent	Place	Node
		# Root		Above	Beetles
		# Root		Below	1
		# 1			Above	Wasps, bees, ants
		# 1			Below	2
		# 2			Above	Butterflies, moths
		# 2			Below	Flies

		if ($count == 1)
		{
			if ( ($fields[0] ne 'Parent') || ($fields[1] ne 'Place') || ($fields[2] ne 'Node') )
			{
				die "Error. Input file line $count is in the wrong format\n";
			}
		}
		else
		{
			if ($#fields <= 1)
			{
				die "Error. Input file line $count does not have enough columns\n";
			}
		}
	}

} # End of read.

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
							: $minimum_y - $top_margin;

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

sub test
{
	my($self) = @_;

	$self -> read;

	$self -> root -> add_daughter(Tree::DAG_Node -> new({name => '', attributes => {place => 'middle'} }) );
	$self -> root -> add_daughter(Tree::DAG_Node -> new({name => 'Beetles', attributes => {place => 'above'} }) );

	my($tree_1) = Tree::DAG_Node -> new({name => '', attributes => {place => 'below'} });

	$self -> root -> add_daughter($tree_1);
	$tree_1 -> add_daughter(Tree::DAG_Node -> new({name => '', attributes => {place => 'middle'} }) );
	$tree_1 -> add_daughter(Tree::DAG_Node -> new({name => 'Wasps, bees, ants', attributes => {place => 'above'} }) );

	my($tree_2) = Tree::DAG_Node -> new({name => '', attributes => {place => 'below'} });

	$tree_1 -> add_daughter($tree_2);
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => '', attributes => {place => 'middle'} }) );
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => 'Butterflies, moths', attributes => {place => 'above'} }) );
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => 'Flies', attributes => {place => 'below'} }) );

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

} # End of test.

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
	Root	Above	Beetles
	Root	Below	1
	1		Above	Wasps, bees, ants
	1		Below	2
	2		Above	Butterflies, moths
	2		Below	Flies

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

	For matching data file, see data/nationalgeographic.01.txt

	Parent	Place	Node
	Root	Above	Archaeopterix lithographica
	Root	Below	1
	1		Above	Apsaravis ukhaana
	1		Below	2
	2		Above	Gansus yumemensis
	2		Below	3
	3		Above	Ichthyornis dispar
	3		Below	4
	4		Above	5
	4		Below	6
	5		Above	Gallus gallus
	5		Below	Anas clypeata
	6		Above	Pasquiaornis
	7		Below	8
	8		Above	Baptornis advenus
	8		Below	9
	9		Above	10
	9		Below	11
	10		Above	Brodavis varnei
	10		Below	Brodavis baileyi
	11		Above	Fumicollis hoffmani
	11		Below	12
	12		Above	Parahesperornis alexi
	12		Below	Hesperornis regalis


=cut
