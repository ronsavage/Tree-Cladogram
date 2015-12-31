package Tree::Cladogram::ImageMagick;

use parent 'Tree::Cladogram';

use Image::Magick;

use Moo;

use Types::Standard qw/Int/;

has title_x =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

has title_y =>
(
	default  => sub{return 0},
	is       => 'rw',
	isa      => Int,
	required => 0,
);

our $VERSION = '1.00';

# ------------------------------------------------

sub BUILD
{
	my($self) = @_;

} # End of BUILD.

# ------------------------------------------------

sub _calculate_leaf_name_bounds
{
	my($self)			= @_;
	my($image)			= Image::Magick -> new(size => '1 x 1');
	my($result)			= $image -> Read('canvas:white');
	my($leaf_font_size)	= $self -> leaf_font_size;
	my($x_step)			= $self -> x_step;

	my($attributes);
	my(@bounds);
	my(@metrics);
	my($x);
	my($y);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)		= @_;
			my(@metrics)	= $image -> QueryFontMetrics
								(
									font		=> $self -> leaf_font_file,
									pointsize	=> $self -> leaf_font_size,
									text		=> $node -> name,
									x			=> 0,
									y			=> 0,
								);
			$attributes				= $node -> attributes;
			$x						= $$attributes{x} + $x_step + 4;
			$y						= $$attributes{y} + int($leaf_font_size / 2);
			@bounds					= ($x, $y, $x + $metrics[11] + 1, $y + $metrics[5]);
			$$attributes{bounds}	= [@bounds];

			$self -> log('Leaf ' . $node -> name
				. '. Bounds ('
				. $metrics[0] . ', ' . $metrics[1] . ') .. ('
				. $metrics[2] . ', ' . $metrics[2] . ')'
			);

			$node -> attributes($attributes);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of _calculate_leaf_name_bounds.

# ------------------------------------------------

sub _calculate_title_metrics
{
	my($self, $image, $maximum_x, $maximum_y) = @_;

	$self -> log('Entered _calculate_title_metrics()');

	my(@metrics) = $image -> QueryFontMetrics
					(
						font		=> $self -> title_font_file,
						pointsize	=> $self -> title_font_size,
						text		=> $self -> title,
						x			=> 0,
						y			=> 0,
					);

	$self -> title_width($metrics[11] + 1);
	$self -> title_x(int( ($maximum_x - $metrics[11]) / 2) );
	$self -> title_y(int( ($maximum_y - $self -> leaf_font_size) / 2) );

	$self -> log('Title metrics:');
	$self -> log($_) for map{"$_: $metrics[$_]"} 0 .. $#metrics;
	$self -> log("Title width: $metrics[11] + 1");
	$self -> log('Leaving _calculate_title_metrics()');

} # End of _calculate_title_metrics.

# ------------------------------------------------

sub create_image
{
	my($self, $maximum_x, $maximum_y) = @_;

	$self -> log("Entered create_image($maximum_x, $maximum_y)");

	my($image) = Image::Magick -> new(size => "$maximum_x x $maximum_y");

	$image -> Read('canvas:white');
	$self -> _calculate_title_metrics($image, $maximum_x, $maximum_y) if (length($self -> title) );

	if ($self -> draw_frame)
	{
		# The advantage of Draw over Border is that the former
		# draws /on/ the image, thereby not making it larger.

		my(@x) = (0, ($maximum_x - 1), ($maximum_x - 1), 0);
		my(@y) = (0, 0, ($maximum_y - 1), ($maximum_y - 1) );

		$image -> Draw
			(
				fill		=> 'none',
				primitive	=> 'polyline',
				points		=> "$x[0],$y[0] $x[1],$y[1] $x[2],$y[2] $x[3],$y[3] $x[0],$y[0]",
				stroke		=> $self -> frame_color,
				strokewidth	=> 1,
			);
	}

	$self -> log('Leaving create_image()');

	return $image;

} # End of create_image.

# ------------------------------------------------

sub draw_horizontal_branch
{
	my($self, $image, $middle_attributes, $daughter_attributes, $final_offset) = @_;
	my($branch_width)	= $self -> branch_width - 1;
	my($x_step)			= $self -> x_step;
	my(@x)				= ($$middle_attributes{x}, $$daughter_attributes{x} + $x_step + $final_offset);
	my(@y)				= ($$daughter_attributes{y}, $$daughter_attributes{y} + $branch_width);
	my($result)			= $image -> Draw
							(
								fill		=> $self -> branch_color,
								method		=> 'replace',
								points		=> "$x[0],$y[0] $x[1],$y[1]",
								primitive	=> 'rectangle',
							);

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
		$image -> Annotate
		(
			font		=> $self -> title_font_file,
			gravity		=> 'west',
			pointsize	=> $self -> title_font_size,
			stroke		=> $self -> title_font_color,
			strokewidth	=> 1,
			text		=> $title,
			x			=> $self -> title_x,
			y			=> $self -> title_y,
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

sub write
{
	my($self, $image, $file_name) = @_;

	$image -> Write($file_name);
	$self -> log('Wrote ' . $file_name);

} # End of write.

# ------------------------------------------------

1;
