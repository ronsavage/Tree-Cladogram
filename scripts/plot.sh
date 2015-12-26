#!/bin/bash

NAME=nationalgeographic
NAME=wikipedia

export NAME

rm $DR/$NAME.01.png

echo $NAME.01.clad

perl -Ilib scripts/plot.pl \
	-i data/$NAME.01.clad \
	-o data/$NAME.01.png \
	-v 1

cp data/$NAME.01.png $DR
