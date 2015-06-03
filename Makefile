LESS = $(wildcard src/*.less)
DIST_CSS = $(LESS:src/%.less=dist/%.css)

HTML = $(wildcard src/*.html)
DIST_HTML = $(HTML:src/%.html=dist/%.html)

SOURCE = src/main.jsx
TARGET = dist/main.js
FLAGS = -t babelify --debug

GOSRC = src/main.go
GOBIN = bin/main

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
	$(BROWSERIFY) $(FLAGS) -o $@ -- $<

watch:
	$(WATCHIFY) --verbose $(FLAGS) -o $(TARGET) -- $(SOURCE)

node_modules:
	$(NPM) install

dist/%.css: src/%.less
	@mkdir -p $(@D)
	@lessc $< > $@

dist/%.html: src/%.html
	@mkdir -p $(@D)
	@rsync -aq $< $@

$(GOBIN): $(GOSRC)
	@go build -o $@ $<

vendor:
	@rsync -aq vendor/ dist/

clean:
	@rm -rf bin/ dist/
