#!/bin/bash

NAME=wikipedia
NAME=nationalgeographic

export NAME

rm -rf data/$NAME.01.png $DR/$NAME.01.png

if [ "$NAME" == "wikipedia" ]; then
	FRAME=1
else
	FRAME=0
fi

export FRAME

#echo $NAME.01.clad

perl -Ilib scripts/plot.pl \
	-font_file /usr/share/fonts/truetype/ttf-bitstream-vera/VeraSe.ttf \
	-font_size 16 \
	-frame_color \#0000ff \
	-i data/$NAME.01.clad \
	-o data/$NAME.01.png \
	-print_frame $FRAME \
	-v 1

cp data/$NAME.01.png $DR
