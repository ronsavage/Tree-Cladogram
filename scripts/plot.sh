#!/bin/bash

NAME=wikipedia
NAME=nationalgeographic

export NAME

rm $DR/$NAME.01.png

echo $NAME.01.clad

perl -Ilib scripts/plot.pl \
	-i data/$NAME.01.clad \
	-o data/$NAME.01.png \

cp data/$NAME.01.png $DR
