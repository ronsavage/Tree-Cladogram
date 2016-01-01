use strict;
use warnings;

use File::Spec;
use File::Temp;

use Imager;

use Test::Stream -V1;

# ------------------------------------------------

sub get_image_specs
{
	my($image) = @_;

} # End of get_image_specs.

# ------------------------------------------------

# The EXLOCK option is for BSD-based systems.

my($file_name)	= 'wikipedia.01.png';
my($temp_dir)	= File::Temp -> newdir('temp.XXXX', CLEANUP => 1, EXLOCK => 0, TMPDIR => 1);
my($temp_file)	= File::Spec -> catfile($temp_dir, $file_name);
my(@images)		= (Imager -> new(file => "data/$file_name"), Imager -> new(file => "data/$file_name") );
my(@specs)		= map{get_image_specs($_)} @images;

is(1, 1, 'Dummy test');

done_testing(0);
