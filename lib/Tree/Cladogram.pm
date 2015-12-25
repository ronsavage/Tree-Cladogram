package Tree::Cladogram;

use Imager;

use Moo;

use Tree::DAG_Node;

use Types::Standard qw/Any Int/;

has child_step =>
(
	default  => sub{return 20},
	is       => 'rw',
	isa      => Int,
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

has root =>
(
	default  => sub{return Tree::DAG_Node -> new({name => 'Root', attributes => {place => 'middle'} })},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has sister_step =>
(
	default  => sub{return 10},
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
	my($self)	= @_;
	my($image)	= Imager -> new(xsize => $self -> maximum_x + 50, y_size => $self -> maximum_y + 50);
	my($blue)	= Imager::Color -> new(0, 0, 255);

	my($attributes);
	my($daughters);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)		= @_;
			$attributes		= $node -> attributes;
			$daughters	= $node -> daughters;

			if ($node -> is_root)
			{
			}
			else
			{
			}

#	$image -> line(color => $blue, x1 => 0, y1 => 0, x2 => 0, y2 => 0);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of plot_image.

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

	$self -> root -> add_daughter(Tree::DAG_Node -> new({name => 'beetles', attributes => {place => 'above'} }) );
	$self -> root -> add_daughter(Tree::DAG_Node -> new({name => '', attributes => {place => 'middle'} }) );

	my($tree_1) = Tree::DAG_Node -> new({name => '', attributes => {place => 'below'} });

	$self -> root -> add_daughter($tree_1);
	$tree_1 -> add_daughter(Tree::DAG_Node -> new({name => 'wasps, bees, ants', attributes => {place => 'above'} }) );
	$tree_1 -> add_daughter(Tree::DAG_Node -> new({name => '', attributes => {place => 'middle'} }) );

	my($tree_2) = Tree::DAG_Node -> new({name => '', attributes => {place => 'below'} });

	$tree_1 -> add_daughter($tree_2);
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => 'butterflies, moths', attributes => {place => 'above'} }) );
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => '', attributes => {place => 'middle'} }) );
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => 'flies', attributes => {place => 'below'} }) );

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
