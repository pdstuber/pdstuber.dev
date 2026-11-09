IMAGE := pdstuber-dev
RESUME_SRC ?= ../resume/resume.md

.PHONY: all clean build serve image run sync-resume

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

# Publishing the resume to the site is a deliberate step; the source lives in the private resume repo.
sync-resume:
	cp $(RESUME_SRC) content/resume.md
