#!/bin/bash

# Great.


# Good.


# OK.


# Just OK.


# Not OK.


# Try.

LEAF_FONT_FILE=/usr/share/fonts/type1/gsfonts/n022003l.pfb
LEAF_FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSans-ExtraLight.ttf

TITLE_FONT_FILE=/usr/share/fonts/truetype/freefont/FreeMono.ttf

echo Font: $LEAF_FONT_FILE

for i in nationalgeographic wikipedia; do

	echo Processing data/$i.01.png

	rm -rf data/$i.02.png $DR/misc/$i.02.png

	if [ "$i" == "wikipedia" ]; then
		FRAME=1
		TITLE='A horizontal cladogram, with the root to the left'
	else
		FRAME=0
		TITLE='The diversity of hesperornithiforms. From Bell and Chiappe, 2015'
	fi

	#echo $NAME.01.clad

	perl -Ilib scripts/image.magick.pl \
		-debug 1 \
		-draw_frame $FRAME \
		-input_file data/$i.01.clad \
		-leaf_font_file $LEAF_FONT_FILE \
		-output_file data/$i.02.png \
		-title "$TITLE" \
		-title_font_file $TITLE_FONT_FILE

	echo -n 'Calling identify ... '

	identify data/$i.02.png

	cp data/$i.02.png $DR/misc

	echo
done
