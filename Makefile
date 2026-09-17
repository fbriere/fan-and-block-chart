IMAGES := fan.png disc.png
ALL_FILES := $(IMAGES) chart-letter.pdf chart-a4.pdf sample.png fan+disc.xcf

OFFSET = $(shell expr $$(identify -format '( %w - %h ) / 2' fan.png))


GIMP_EXPORT_SCRIPT = (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE \"$<\" \"$<\"))) \
		      (drawable (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))) \
	      (gimp-file-save RUN-NONINTERACTIVE image drawable \"$$WORKDIR/$@\" \"$$WORKDIR/$@\") \
	      (gimp-image-delete image))

GIMP_COMBINE_SCRIPT = (let* ((image (car (gimp-image-new 1 1 GRAY))) \
	                   (fan-layer (car (gimp-file-load-layer RUN-NONINTERACTIVE image \"fan.png\"))) \
	                   (disc-layer (car (gimp-file-load-layer RUN-NONINTERACTIVE image \"disc.png\")))) \
	      (gimp-image-insert-layer image fan-layer 0 -1) \
	      (gimp-item-set-name fan-layer \"Fan\") \
	      (gimp-image-insert-layer image disc-layer 0 -1) \
	      (gimp-item-set-name disc-layer \"Disc\") \
	      (gimp-layer-set-offsets disc-layer $(OFFSET) $(OFFSET)) \
	      (gimp-image-resize-to-layers image) \
	      (gimp-xcf-save RUN-NONINTERACTIVE image fan-layer \"$@\" \"$@\") \
	      (gimp-image-delete image))


all: $(ALL_FILES)

$(IMAGES): %.png: %.xcf
	WORKDIR="$$(mktemp -d "$${TMPDIR:-/tmp}/fan-and-block.XXXXXXXX")"; \
		[ "$$WORKDIR" ] && \
		gimp --no-interface \
			--batch "$(GIMP_EXPORT_SCRIPT)" \
			--batch '(gimp-quit 0)' && \
		convert -strip "$$WORKDIR/$@" "$@" && \
		rm -rf "$$WORKDIR"

sample.png: $(IMAGES)
	convert -strip \
		\( fan.png -virtual-pixel background -background none -gravity south -splice "x$(OFFSET)" \) \
		\( disc.png -virtual-pixel background -background none -distort SRT 30 \) \
		-gravity south -composite -resize '15%' $@

fan+disc.xcf: $(IMAGES)
	gimp --no-interface \
		--batch "$(GIMP_COMBINE_SCRIPT)" \
		--batch '(gimp-quit 0)'

# For --engine=internal : https://gitlab.mister-muffin.de/josch/img2pdf/issues/150
chart-%.pdf: $(IMAGES)
	@WORKDIR="$$(mktemp -d "$${TMPDIR:-/tmp}/fan-and-block.XXXXXXXX")"; \
		[ "$$WORKDIR" ] && \
		for f in fan.png disc.png; do \
			convert -strip $$f -background white -alpha remove -alpha off "$$WORKDIR/$$f" || exit 1; \
		done && \
		convert "$$WORKDIR/fan.png" -rotate 270 "$$WORKDIR/fan-rotated.png" && \
		img2pdf --engine=internal --nodate -S $* -s 150dpi "$$WORKDIR/fan-rotated.png" "$$WORKDIR/disc.png" --output $@ && \
		rm -rf "$$WORKDIR"


.PHONY: all
