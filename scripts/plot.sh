#!/bin/bash
#
# Note: Imager was used to render the text.

# Great.

FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraMoBd.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationMono-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraSeBd.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraSe.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeMono.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSansBold.ttf
FONT_FILE=/usr/share/fonts/truetype/droid/DroidSans-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSans-BoldOblique.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBI.ttf

# Good.

FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationMono-BoldItalic.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraMono.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraMoIt.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium-basic/GenBasR.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationMono-Regular.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSerif-Bold.ttf
FONT_FILE=/usr/local/share/fonts/truetype/gothic.ttf

# OK.

FONT_FILE=/usr/share/fonts/truetype/droid/DroidSansMono.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium-basic/GenBkBasR.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeMonoBold.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeMonoOblique.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeMonoBoldOblique.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSansBoldOblique.ttf
FONT_FILE=/usr/share/fonts/truetype/droid/DroidSerif-Bold.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-BoldOblique.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Oblique.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
FONT_FILE=/usr/local/share/fonts/truetype/gothic.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraIt.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraMoBI.ttf

# Just OK.

FONT_FILE=/usr/share/fonts/truetype/gentium/GenR102.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationMono-Italic.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSansNarrow-Regular.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSerif-BoldItalic.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSerif-Italic.ttf
FONT_FILE=/usr/share/fonts/opentype/stix-word/STIX-Regular.otf
FONT_FILE=/usr/local/share/fonts/truetype/monofont.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium-basic/GenBkBasI.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium-basic/GenBasI.ttf
FONT_FILE=/usr/share/fonts/truetype/gentium-basic/GenBasBI.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSans.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSansOblique.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSerif.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSerifBold.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSerifItalic.ttf
FONT_FILE=/usr/share/fonts/truetype/droid/DroidSans.ttf

# Not OK.
# *.pfb
# *.otf
# And ...

FONT_FILE=/usr/share/fonts/truetype/droid/DroidSans.ttf
FONT_FILE=/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Italic.ttf
FONT_FILE=/usr/share/fonts/truetype/freefont/FreeSerifBoldItalic.ttf
FONT_FILE=/usr/share/fonts/truetype/droid/DroidSerif-BoldItalic.ttf
FONT_FILE=/usr/share/fonts/truetype/droid/DroidSerif-Regular.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSerif-BoldItalic.ttf
FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSerif-Italic.ttf

# Try.

FONT_FILE=/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf

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
