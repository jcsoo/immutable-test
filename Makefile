LESS = $(wildcard src/*.less)
DIST_CSS = $(LESS:src/%.less=dist/%.css)

SRC = $(wildcard src/*.js src/*.jsx)
DIST_JS = $(SRC:src/%.js=dist/%.js)
DIST_JSX = $(SRC:src/%.jsx=dist/%.js)

HTML = $(wildcard src/*.html)
DIST_HTML = $(HTML:src/%.html=dist/%.html)

GOSRC = src/main.go

GOBIN = bin/main

.PHONY: clean bin dist vendor

all: build

build: bin dist vendor

bin: bin/main

dist: $(DIST_JS) $(DIST_JSX) $(DIST_CSS) $(DIST_HTML)

dist/%.js: src/%.js
	@mkdir -p $(@D)
	@babel $< -o $@

dist/%.js: src/%.jsx
	@mkdir -p $(@D)
	@babel $< -o $@

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
