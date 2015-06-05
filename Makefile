IMAGE=immutable-test

CSS_SRC = $(wildcard src/client/*.less)
CSS = $(LESS:src/%.less=dist/%.css)
LESSC_FLAGS = --source-map-map-inline

HTML_SRC = $(wildcard src/server/html/*.html)
HTML = $(HTML_SRC:src/%.html=dist/%.html)

CLIENT_SRC = $(wildcard src/client/*.jsx) $(wildcard src/client/*.js)
CLIENT = dist/client/main.js
CLIENT_BROWSERIFY_FLAGS = -t babelify -x immutable -x blackbird -x xhr-promise --debug
LIB_FLAGS = -r immutable -r blackbird -r xhr-promise

SERVER_SRC = $(wildcard src/server/*.jsx) $(wildcard src/server/*.js)
SERVER = dist/server/main.js
SERVER_BROWSERIFY_FLAGS =

COMMON_JSX = $(wildcard src/common/*.jsx)
COMMON_JS = $(wildcard src/common/*.js)
COMMON = $(COMMON_JS:src/%.js=dist/%.js) $(COMMON_JSX:src/%.jsx=dist/%.js)

GOSRC = src/main.go
GOBIN = bin/main

LESSC = ./node_modules/.bin/lessc
WATCHIFY = ./node_modules/.bin/watchify
BROWSERIFY = ./node_modules/.bin/browserify
BABEL = ./node_modules/.bin/babel
NPM = npm
NPM_FLAGS =
LIB = immutable blackbird

.PHONY: clean bin dist gulp lib vendor run watch watchify watchman go-builder node-builder bin-image dist-image vendor-image image run-image


all: build

build: dist lib vendor

bin: bin/main

dist: $(SERVER) $(CLIENT) $(COMMON) $(CSS) $(HTML)

gulp:
	@gulp

$(CLIENT): $(CLIENT_SRC) node_modules
	@mkdir -p $(@D)
	@$(BROWSERIFY) $(CLIENT_BROWSERIFY_FLAGS) -o $@.tmp -- $<
	@mv $@.tmp $@

watch:
	@fswatch src | xargs -n1 -I {} sh -c 'make dist && afplay /System/Library/Sounds/Pop.aiff || afplay /System/Library/Sounds/Basso.aiff'

node_modules:
	@$(NPM) $(NPM_FLAGS) install

dist/%.js: src/%.js
	@mkdir -p $(@D)
	$(BABEL) -o $@ $?

dist/%.js: src/%.jsx
	@mkdir -p $(@D)
	$(BABEL) -o $@ $?

dist/%.css: src/%.less
	@mkdir -p $(@D)
	@$(LESSC) $(LESSC_FLAGS) $< $@

dist/%.html: src/%.html
	@mkdir -p $(@D)
	@rsync -aq $< $@

$(GOBIN): $(GOSRC)
	@go get github.com/julienschmidt/httprouter
	@go build -o $@ $<

lib: dist/lib.js

dist/lib.js: node_modules
	@mkdir -p $(@D)
	@$(BROWSERIFY) $(LIB_FLAGS) -o dist/client/lib.js

vendor:
	@rsync -aq vendor/ dist/client/

clean:
	@rm -rf bin/ dist/

reallyclean: clean
	@rm -rf node_modules/

run: dist
	node dist/server/main.js

run-go: dist bin
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
