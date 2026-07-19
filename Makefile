IMAGES := fan.png disc.png

all: $(IMAGES) chart-letter.pdf chart-a4.pdf

GIMP_SCRIPT = (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) \
		      (drawable (car (gimp-image-flatten image)))) \
	      (gimp-file-save RUN-NONINTERACTIVE image drawable "$@" "$@") \
	      (gimp-image-delete image))

%.png: %.xcf
	gimp --no-interface \
		--batch '$(GIMP_SCRIPT)' \
		--batch '(gimp-quit 0)'

chart-%.pdf: $(IMAGES)
	@TEMP_FILE=$$(mktemp "$${TMPDIR:-/tmp}/fan-and-block-rotated.XXXXXXXX"); \
		  convert fan.png -rotate 270 $$TEMP_FILE && \
		  img2pdf --nodate -S $* -s 150dpi $$TEMP_FILE disc.png --output $@ && \
		  rm $$TEMP_FILE

.PHONY: all
