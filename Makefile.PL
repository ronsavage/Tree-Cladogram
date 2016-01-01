use strict;
use warnings;

use ExtUtils::MakeMaker;

# ----------------

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		AUTHOR   => 'Ron Savage (ron@savage.net.au)',
		ABSTRACT => 'Render a tree as a cladogram',
	) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST Tree-Cladogram-*'
	},
	dist =>
	{
		COMPRESS => 'gzip',
		SUFFIX   => 'gz'
	},
	DISTNAME  => 'Tree-Cladogram',
	NAME      => 'Tree::Cladogram',
	LICENSE   => 'artistic_2',
	PL_FILES  => {},
	PREREQ_PM =>
	{
		'File::Slurper'		=> 0.008,
		'Getopt::Long'		=> 0,
		#'Image::Magick'	=> 6.9.3, # Image::Magick is optional.
		'Imager'			=> 1.004,
		'Imager::Fill'		=> 1.012,
		'Moo'				=> 2.000002,
		'parent'			=> 0,
		'Pod::Usage'		=> 1.67,
		'strict'			=> 0,
		'Test::More'		=> 1.001014,
		'Test::Stream'		=> 1.302026,
		'Test::Pod'			=> 1.48,
		'Tree::DAG_Node'	=> 1.27,
		'Types::Standard'	=> 1.00000,
		'warnings'			=> 0,
	},
	VERSION_FROM => 'lib/Tree/Cladogram.pm',
);
