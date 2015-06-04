IMAGE=immutable-test

LESS = $(wildcard src/*.less)
DIST_CSS = $(LESS:src/%.less=dist/%.css)
LESSC_FLAGS = --source-map-map-inline

HTML = $(wildcard src/*.html)
DIST_HTML = $(HTML:src/%.html=dist/%.html)

SOURCE = $(wildcard src/*.jsx) $(wildcard src/*.js)
TARGET = dist/main.js
BROWSERIFY_FLAGS = -t babelify --debug

GOSRC = src/main.go
GOBIN = bin/main

LESSC = ./node_modules/.bin/lessc
WATCHIFY = ./node_modules/.bin/watchify
BROWSERIFY = ./node_modules/.bin/browserify
NPM = npm

.PHONY: clean bin dist gulp vendor run watch watchify watchman go-builder image

all: build

build: bin dist vendor

bin: bin/main

dist: $(TARGET) $(DIST_CSS) $(DIST_HTML)

gulp:
	@gulp

$(TARGET): $(SOURCE) node_modules
	@mkdir -p $(@D)
	@$(BROWSERIFY) $(BROWSERIFY_FLAGS) -o $@.tmp -- $<
	@mv $@.tmp $@

watch:
	@fswatch src | xargs -n1 -I {} sh -c 'make dist && afplay /System/Library/Sounds/Pop.aiff || afplay /System/Library/Sounds/Basso.aiff'

watchify:
	$(WATCHIFY) --verbose $(BROWSERIFY_FLAGS) -o $(TARGET) -- $(SOURCE)

node_modules:
	$(NPM) install

dist/%.css: src/%.less
	@mkdir -p $(@D)
	@$(LESSC) $(LESSC_FLAGS) $< $@

dist/%.html: src/%.html
	@mkdir -p $(@D)
	@rsync -aq $< $@

$(GOBIN): $(GOSRC)
	@go get github.com/julienschmidt/httprouter
	@go build -o $@ $<

vendor:
	@rsync -aq vendor/ dist/

clean:
	@rm -rf bin/ dist/

run: build
	@bin/main

go-builder:
	docker build -t go-builder -f docker/go-builder.docker .

node-builder:
	docker build -t node-builder -f docker/node-builder.docker .

bin-image: go-builder
	@mkdir -p $(@D)
	docker run --rm -it -v $(PWD):/go go-builder make bin

dist-image: node-builder
	@mkdir -p $(@D)
	docker run --rm -it -v $(PWD):/src node-builder make dist

vendor-image: vendor
	@mkdir -p $(@D)

image: vendor-image dist-image bin-image
	docker build -t $(IMAGE) -f docker/Dockerfile .

run-image: image
	docker run --rm -it -p 5000:5000 $(IMAGE)

