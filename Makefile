LESS = $(wildcard src/*.less)
DIST_CSS = $(LESS:src/%.less=dist/%.css)

SRC = $(wildcard src/*.js)
DIST_JS = $(SRC:src/%.js=dist/%.js)

HTML = $(wildcard src/*.html)
DIST_HTML = $(HTML:src/%.html=dist/%.html)

GOSRC = src/main.go

GOBIN = bin/main

.phony: clean

all: build

build: dist bin/main

dist: $(DIST_JS) $(DIST_CSS)

dist/%.js: src/%.js
	@mkdir -p $(@D)
	@babel $< -o $@

dist/%.css: src/%.less
	@mkdir -p $(@D)
	@lessc $< > $@

dist/%.html: src/%.html
	@mkdir -p $(@D)
	@cp $< $@

$(GOBIN): $(GOSRC)
	@go build -o $@ $<

clean:
	@rm -rf bin/ dist/
