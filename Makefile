IMAGES := fan.png disc.png

all: $(IMAGES) chart-letter.pdf chart-a4.pdf

GIMP_SCRIPT = (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) \
		      (drawable (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))) \
	      (gimp-file-save RUN-NONINTERACTIVE image drawable "$@" "$@") \
	      (gimp-image-delete image))

$(IMAGES): %.png: %.xcf
	gimp --no-interface \
		--batch '$(GIMP_SCRIPT)' \
		--batch '(gimp-quit 0)'

sample.png: $(IMAGES)
	@PAD=$$(expr $$(identify -format '( %w - %h ) / 2' fan.png)); \
	    convert \
		\( fan.png -virtual-pixel background -background none -gravity south -splice "x$$PAD" \) \
		\( disc.png -virtual-pixel background -background none -distort SRT 30 \) \
		-gravity south -composite -resize '15%' $@

chart-%.pdf: $(IMAGES)
	@WORKDIR="$$(mktemp -d "$${TMPDIR:-/tmp}/fan-and-block.XXXXXXXX")"; \
		[ "$$WORKDIR" ] && \
		for f in fan.png disc.png; do \
			convert $$f -background white -alpha remove -alpha off "$$WORKDIR/$$f"; \
		done && \
		convert "$$WORKDIR/fan.png" -rotate 270 "$$WORKDIR/fan-rotated.png" && \
		img2pdf --nodate -S $* -s 150dpi "$$WORKDIR/fan-rotated.png" "$$WORKDIR/disc.png" --output $@ && \
		rm -rf "$$WORKDIR"

.PHONY: all
