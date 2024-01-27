.PHONY: all
all: clean build

.PHONY: clean
clean:
	rm -rf resources public

.PHONY: build
build:
	hugo --gc --minify
