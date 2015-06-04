LESS = $(wildcard src/*.less)
DIST_CSS = $(LESS:src/%.less=dist/%.css)
LESSC_FLAGS = --source-map-map-inline

HTML = $(wildcard src/*.html)
DIST_HTML = $(HTML:src/%.html=dist/%.html)

SOURCE = $(wildcard src/*.jsx) $(wildcard src/*.js)
TARGET = dist/main.js
BROWSERIFY_FLAGS = -t babelify -x immutable -x blackbird -x xhr-promise --debug
LIB_FLAGS = -r immutable -r blackbird -r xhr-promise

GOSRC = src/main.go
GOBIN = bin/main

LESSC = ./node_modules/.bin/lessc
WATCHIFY = ./node_modules/.bin/watchify
BROWSERIFY = ./node_modules/.bin/browserify
NPM = npm
NPM_FLAGS = 

LIB = immutable blackbird

.PHONY: clean bin dist gulp lib vendor run watch watchify watchman

all: build

build: bin dist lib vendor

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
	@$(NPM) $(NPM_FLAGS) install

dist/%.css: src/%.less
	@mkdir -p $(@D)
	@$(LESSC) $(LESSC_FLAGS) $< $@

dist/%.html: src/%.html
	@mkdir -p $(@D)
	@rsync -aq $< $@

$(GOBIN): $(GOSRC)
	@go build -o $@ $<

lib: node_modules
	@$(BROWSERIFY) $(LIB_FLAGS) -o dist/lib.js

vendor:
	@rsync -aq vendor/ dist/

clean:
	@rm -rf bin/ dist/

reallyclean: clean
	@rm -rf node_modules/

run: build
	@bin/main
