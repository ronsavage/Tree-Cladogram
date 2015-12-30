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
