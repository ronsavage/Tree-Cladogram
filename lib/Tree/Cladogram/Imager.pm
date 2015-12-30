package Tree::Cladogram::Imager;

use parent 'Tree::Cladogram';

use Imager;
use Imager::Fill;

use Moo;

use Types::Standard qw/Any Int Str/;

has leaf_font =>
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

has title_font =>              # Internal.
(
	default  => sub{return ''},
	is       => 'rw',
	isa      => Any,
	required => 0,
);

our $VERSION = '1.00';

# ------------------------------------------------

sub BUILD
{
	my($self) = @_;

	$self -> leaf_font
	(
		Imager::Font -> new
		(
			color	=> Imager::Color -> new($self -> leaf_font_color),
			file	=> $self -> leaf_font_file,
			size	=> $self -> leaf_font_size,
			utf8	=> 1
		) || die "Error. Can't define leaf font: " . Imager -> errstr
	);
	$self -> title_font
	(
		Imager::Font -> new
		(
			color	=> Imager::Color -> new($self -> title_font_color),
			file	=> $self -> title_font_file,
			size	=> $self -> title_font_size,
			utf8	=> 1
		) || die "Error. Can't define title font: " . Imager -> errstr
	);

	if (length($self -> title) )
	{
		my(@bounds) = $self -> title_font -> align
						(
							halign	=> 'left',
							image	=> undef,
							string	=> $self -> title,
							valign	=> 'baseline',
							x		=> 0,
							y		=> 0,
						);

		$self -> title_width($bounds[2]);
	}

} # End of BUILD.

# ------------------------------------------------

sub create_image
{
	my($self, $maximum_x, $maximum_y) = @_;

	my($image)			= Imager -> new(xsize => $maximum_x, ysize => $maximum_y);
	my($frame_color)	= Imager::Color -> new($self -> frame_color);
	my($white)			= Imager::Color -> new(255, 255, 255);

	$image -> box(color => $white, filled => 1);
	$image -> box(color => $frame_color) if ($self -> draw_frame);

	return $image;

} # End of create_image.

# ------------------------------------------------

sub draw_horizontal_branch
{
	my($self, $image, $middle_attributes, $daughter_attributes, $final_offset) = @_;
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

} # End of draw_horizontal_branch.

# ------------------------------------------------

sub draw_leaf_name
{
	my($self, $image, $name, $daughter_attributes, $final_offset) = @_;

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

} # End of draw_leaf_name.

# ------------------------------------------------

sub draw_root_branch
{
	my($self, $image)			= @_;
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

} # End of draw_root_branch.

# ------------------------------------------------

sub draw_title
{
	my($self, $image, $maximum_x, $maximum_y) = @_;
	my($title) = $self -> title;

	if (length($title) > 0)
	{
		my(@bounds) = $self -> title_font -> align
						(
							halign	=> 'left',
							image	=> undef,
							string	=> $title,
							valign	=> 'baseline',
							x		=> 0,
							y		=> 0,
						);

		$image -> string
		(
			align	=> 0,
			font	=> $self -> title_font,
			string	=> $title,
			x		=> int( ($maximum_x - $bounds[2]) / 2),
			y		=> $maximum_y - $self -> top_margin,
		);
	}

} # End of draw_title.

# ------------------------------------------------

sub draw_vertical_branch
{
	my($self, $image, $middle_attributes, $daughter_attributes) = @_;
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

} # End of draw_vertical_branch.

# ------------------------------------------------

sub place_text
{
	my($self)			= @_;
	my($leaf_font_size)	= $self -> leaf_font_size;
	my($x_step)			= $self -> x_step;

	my($attributes);
	my(@bounds);

	$self -> root -> walk_down
	({
		callback =>
		sub
		{
			my($node)	= @_;
			$attributes	= $node -> attributes;
			@bounds		= $self -> leaf_font -> align
							(
								halign	=> 'left',
								image	=> undef,
								string	=> $node -> name,
								valign	=> 'baseline',
								x		=> $$attributes{x} + $x_step + 4,
								y		=> $$attributes{y} + int($leaf_font_size / 2),
							);
			$$attributes{bounds} = [@bounds];

			$node -> attributes($attributes);

			return 1; # Keep walking.
		},
		_depth	=> 0,
	});

} # End of place_text.

# ------------------------------------------------

1;