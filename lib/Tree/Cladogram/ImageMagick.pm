package Tree::Cladogram::ImageMagick;

use parent 'Tree::Cladogram';

use Image::Magick;

use Moo;

use Types::Standard qw/Any Int Str/;

our $VERSION = '1.00';

# ------------------------------------------------

sub BUILD
{
	my($self) = @_;

	$self -> _calculate_title_metrics;

} # End of BUILD.

# ------------------------------------------------

sub _calculate_leaf_name_bounds
{
	my($self)			= @_;
	my($image)			= Image::Magick -> new;
	my($leaf_font_size)	= $self -> leaf_font_size;
	my($x_step)			= $self -> x_step;

	my($attributes);
	my(@metrics);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)		= @_;
			$attributes		= $node -> attributes;
			my(@metrics)	= $image -> QueryFontMetrics
							(
								font		=> $self -> leaf_font_file,
								pointsize	=> $self -> leaf_font_size,
								text		=> $node -> name,
								x			=> $$attributes{x} + $x_step + 4,
								y			=> $$attributes{y} + int($leaf_font_size / 2),
							);
			print 'Leaf metrics (', $node -> name, ') ', join("\n", map{"$_: $metrics[$_]"} 0 .. $#metrics), ". \n";

			$$attributes{bounds} = [@metrics[7 .. 10] ];

			$node -> attributes($attributes);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of _calculate_leaf_name_bounds.

# ------------------------------------------------

sub _calculate_title_metrics
{
	my($self) = @_;

	if (length($self -> title) )
	{
		my($image)		= Image::Magick -> new;
		my(@metrics)	= $image -> QueryFontMetrics
							(
								font		=> $self -> leaf_font_file,
								pointsize	=> $self -> leaf_font_size,
								text		=> $self -> title,
								x			=> 0,
								y			=> 0,
							);

		$self -> title_width($metrics[4] || 0);

		print "Title metrics: \n", join("\n", map{"$_: $metrics[$_]"} 0 .. $#metrics), ". \n";
		print "Title width:   $metrics[4]. \n";
	}

} # End of _calculate_title_metrics.

# ------------------------------------------------

sub create_image
{
	my($self, $maximum_x, $maximum_y) = @_;
	my($image) = Image::Magick -> new(width => 1, height => 1);

	$image -> Read('canvas:white');
	$image -> Frame(fill => $self -> frame_color, width => 1, height => 1) if ($self -> draw_frame);

	return $image;

} # End of create_image.

# ------------------------------------------------

sub draw_horizontal_branch
{
	my($self, $image, $middle_attributes, $daughter_attributes, $final_offset) = @_;

=pod

	my($branch_color)	= $self -> branch_color;
	my($branch_width)	= $self -> branch_width - 1;
	my($x_step)			= $self -> x_step;

	$image -> box
	(
		box =>
		[
			$$middle_attributes{x},
			$$daughter_attributes{y},
			$$daughter_attributes{x} + $x_step + $final_offset,
			$$daughter_attributes{y} + $branch_width,
		],
		color	=> $branch_color,
		filled	=> 1,
	);

=cut

} # End of draw_horizontal_branch.

# ------------------------------------------------

sub draw_leaf_name
{
	my($self, $image, $name, $daughter_attributes, $final_offset) = @_;

=pod

	if ( (length($name) > 0) && ($name !~ /^\d+$/) )
	{
		my($bounds) 	= $$daughter_attributes{bounds};
		$$bounds[0]		+= $final_offset;
		$$bounds[2]		+= $final_offset;
		my($fuschia)	= Imager::Color -> new(0xff, 0, 0xff);

		$image -> string
		(
			align	=> 0,
			font	=> $self -> leaf_font,
			string	=> $name,
			x		=> $$bounds[0],
			y		=> $$bounds[1],
		);

		if ($self -> debug && 0)
		{
			$image -> box
			(
				box		=> $bounds,
				color	=> $fuschia,
				filled	=> 0,
			);
		}
	}

=cut

} # End of draw_leaf_name.

# ------------------------------------------------

sub draw_root_branch
{
	my($self, $image)			= @_;

=pod

	my($branch_color)			= $self -> branch_color;
	my($branch_width)			= $self -> branch_width - 1;
	my($attributes)				= $self -> root -> attributes;
	my(@daughters)				= $self -> root -> daughters;
	my($daughter_attributes)	= $daughters[0] -> attributes;

	$image -> box
	(
		box =>
		[
			$$daughter_attributes{x},
			$$daughter_attributes{y},
			$self -> left_margin,
			$$attributes{y} + $branch_width,
		],
		color	=> $branch_color,
		filled	=> 1,
	);

=cut

} # End of draw_root_branch.

# ------------------------------------------------

sub draw_title
{
	my($self, $image, $maximum_x, $maximum_y) = @_;
	my($title) = $self -> title;

	if (length($title) > 0)
	{
		my(@metrics) = $image -> QueryFontMetrics
						(
							font		=> $self -> leaf_font_file,
							pointsize	=> $self -> leaf_font_size,
							text		=> $title,
							x			=> 0,
							y			=> 0,
						);

		$image -> Annotate
		(
			font		=> $self -> leaf_font_file,
			pointsize	=> $self -> leaf_font_size,
			text		=> $title,
			x			=> int( ($maximum_x - $metrics[4]) / 2),
			y			=> $maximum_y - $self -> top_margin,
		);
	}

} # End of draw_title.

# ------------------------------------------------

sub draw_vertical_branch
{
	my($self, $image, $middle_attributes, $daughter_attributes) = @_;

=pod

	my($branch_color)	= $self -> branch_color;
	my($branch_width)	= $self -> branch_width - 1;

	$image -> box
	(
		box =>
		[
			$$middle_attributes{x},
			$$middle_attributes{y},
			$$middle_attributes{x} + $branch_width,
			$$daughter_attributes{y},
		],
		color	=> $branch_color,
		filled	=> 1,
	);

=cut

} # End of draw_vertical_branch.

# ------------------------------------------------

1;
