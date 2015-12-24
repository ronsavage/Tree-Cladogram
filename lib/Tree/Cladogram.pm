package Tree::Cladogram;

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
	my($direction);
	my($parent_attributes);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node, $options)			= @_;
			$attributes					= $node -> attributes;
			$$attributes{child_step}	||= $child_step;
			$$attributes{sister_step}	||= $sister_step;

			if ($node -> is_root)
			{
				$$attributes{x}	= 0;
				$$attributes{y} = 0;
			}
			else
			{
				$direction			= $$attributes{place} eq 'above'
										? -1
										: $$attributes{place} eq 'middle'
											? 0
											: 1;
				$parent_attributes	= $node -> mother -> attributes;
				$$attributes{x}		= $$parent_attributes{x} + $$attributes{child_step};
				$$attributes{y}		= $$parent_attributes{y} + $direction * $$attributes{sister_step};
			}

			$node -> attributes($attributes);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of compute_co_ords.

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

			$node -> attributes($attributes);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

	$self -> minimum_y($minimum_y);

} # End of find_minimum_y.

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
	$self -> find_minimum_y;

	print 'minimum_y:  ', $self -> minimum_y, "\n";
	print 'top_margin: ', $self -> top_margin, "\n";

	$self -> shift_image if ($self -> minimum_y <= $self -> top_margin);

	print map("$_\n", @{$self -> root -> tree2string({no_attributes => 0})}), "\n";

} # End of test.

# ------------------------------------------------

1;
