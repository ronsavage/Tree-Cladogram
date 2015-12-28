#!/bin/bash
#
# $DR is my web server's doc root within Debian's RAM disk :-).
# The latter is at /run/shm, so $DR is /run/shm/html.

pod2html.pl -i lib/Tree/Cladogram.pm -o $DR/Perl-modules/html/Tree/Cladogram.html
