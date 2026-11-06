IMAGE := pdstuber-dev

.PHONY: all clean build serve image run

all: clean build

clean:
	rm -rf resources public

build:
	hugo --gc --minify

serve:
	hugo server

image:
	container build -t $(IMAGE) .

run: image
	container run --rm -p 8080:8080 $(IMAGE)
