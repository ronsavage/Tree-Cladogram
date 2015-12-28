#!/bin/bash

FONT_FILE=/usr/share/fonts/truetype/droid/DroidSans.ttf
FONT_FILE=/usr/local/share/fonts/truetype/gothic.ttf
FONT_FILE=/usr/local/share/fonts/truetype/monofont.ttf
FONT_FILE=/usr/share/fonts/opentype/stix-word/STIX-Regular.otf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSansNarrow-Regular.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium/GenR102.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium-basic/GenBkBasR.ttf
FONT_FILE=/usr/share/fonts/truetype/droid/DroidSansMono.ttf

export FONT_FILE

echo Font: $FONT_FILE

for i in nationalgeographic wikipedia; do

	rm -rf data/$i.01.png $DR/$i.01.png

	if [ "$i" == "wikipedia" ]; then
		FRAME=1
	else
		FRAME=0
	fi

	export FRAME

	#echo $NAME.01.clad

	perl -Ilib scripts/plot.pl \
		-draw_frame $FRAME \
		-font_file $FONT_FILE \
		-font_size 16 \
		-frame_color \#0000ff \
		-input_file data/$i.01.clad \
		-output_file data/$i.01.png \
		-verbose 1

	identify data/$i.01.png

	cp data/$i.01.png $DR
done
