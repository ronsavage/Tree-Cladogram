package Tree::Cladogram;

use Moo;

use Tree::DAG_Node;

use Types::Standard qw/Any/;

has root =>
(
	default  => sub{return Tree::DAG_Node -> new({name => 'Root'})},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

our $VERSION = '1.00';

# ------------------------------------------------

# ------------------------------------------------

# ------------------------------------------------

sub test
{
	my($self) = @_;

	$self -> root -> add_daughter(Tree::DAG_Node -> new({name => 'beetles', attributes => {above => 1} }) );

	my($tree_1) = Tree::DAG_Node -> new({name => '+', attributes => {above => 0} });

	$tree_1 -> add_daughter(Tree::DAG_Node -> new({name => 'wasps, bees, ants', attributes => {above => 1} }) );
	$self -> root -> add_daughter($tree_1);

	my($tree_2) = Tree::DAG_Node -> new({name => '+', attributes => {above => 0} });

	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => 'butterflies, moths', attributes => {above => 1} }) );
	$tree_2 -> add_daughter(Tree::DAG_Node -> new({name => 'flies', attributes => {above => 0} }) );

	$tree_1 -> add_daughter($tree_2);

	print map("$_\n", @{$self -> root -> tree2string({no_attributes => 0})}), "\n";

} # End of test.

# ------------------------------------------------

1;
