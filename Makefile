LESS = $(wildcard src/*.less)
DIST_CSS = $(LESS:src/%.less=dist/%.css)
LESSC_FLAGS = --source-map-map-inline

HTML = $(wildcard src/*.html)
DIST_HTML = $(HTML:src/%.html=dist/%.html)

SOURCE = src/main.jsx
TARGET = dist/main.js
BROWSERIFY_FLAGS = -t babelify --debug

GOSRC = src/main.go
GOBIN = bin/main

LESSC = ./node_modules/.bin/lessc
WATCHIFY = ./node_modules/.bin/watchify
BROWSERIFY = ./node_modules/.bin/browserify
NPM = npm

.PHONY: clean bin dist vendor

all: build

build: bin dist vendor

bin: bin/main

dist: $(TARGET) $(DIST_CSS) $(DIST_HTML)

$(TARGET): $(SOURCE) node_modules
	@mkdir -p $(@D)
	$(BROWSERIFY) $(BROWSERIFY_FLAGS) -o $@ -- $<

watch:
	$(WATCHIFY) --verbose $(BROWSERIFY_FLAGS) -o $(TARGET) -- $(SOURCE)

node_modules:
	$(NPM) install

dist/%.css: src/%.less
	@mkdir -p $(@D)
	$(LESSC) $(LESSC_FLAGS) $< $@

dist/%.html: src/%.html
	@mkdir -p $(@D)
	@rsync -aq $< $@

$(GOBIN): $(GOSRC)
	@go build -o $@ $<

vendor:
	@rsync -aq vendor/ dist/

clean:
	@rm -rf bin/ dist/
