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
		ABSTRACT => 'Manage the "flowers" database',
	) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST Local-Flowers-*'
	},
	dist =>
	{
		COMPRESS => 'gzip',
		SUFFIX   => 'gz'
	},
	DISTNAME  => 'Local-Flowers',
	NAME      => 'Local::Flowers',
	LICENSE   => 'artistic_2',
	PL_FILES  => {},
	PREREQ_PM =>
	{
		'Moo'				=> 2.000002,
		'strict'			=> 0,
		'Test::More'		=> 1.001014,
		'Test::Stream'		=> 1.302026,
		'Test::Pod'			=> 1.48,
		'Tree::DAG_Node'	=> 1.27,
		'Types::Standard'	=> 1.00000,
		'warnings'			=> 0,
	},
	VERSION_FROM => 'lib/Local/Flowers.pm',
);
