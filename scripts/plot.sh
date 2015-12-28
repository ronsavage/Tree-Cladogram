#!/bin/bash

NAME=nationalgeographic
NAME=wikipedia

export NAME

rm -rf data/$NAME.01.png $DR/$NAME.01.png

if [ "$NAME" == "wikipedia" ]; then
	FRAME=1
else
	FRAME=0
fi

export FRAME

#echo $NAME.01.clad

#	-font_file /usr/share/fonts/truetype/ttf-bitstream-vera/VeraSe.ttf \

perl -Ilib scripts/plot.pl \
	-draw_frame $FRAME \
	-font_size 16 \
	-frame_color \#0000ff \
	-input_file data/$NAME.01.clad \
	-output_file data/$NAME.01.png \
	-verbose 1

cp data/$NAME.01.png $DR
