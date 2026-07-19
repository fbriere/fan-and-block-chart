IMAGES := fan.png disc.png

all: $(IMAGES)

%.png: %.xcf
	gimp --no-interface --batch \
		'(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) (drawable (car (gimp-image-flatten image)))) (gimp-file-save RUN-NONINTERACTIVE image drawable "$@" "$@") (gimp-image-delete image))' -b '(gimp-quit 0)'

.PHONY: all
