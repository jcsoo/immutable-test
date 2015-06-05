IMAGE=immutable-test

CSS_SRC = $(shell find src/client -type f -name '*.less')
CSS = $(CSS_SRC:src/%.less=dist/%.css)

HTML_SRC = $(shell find src/server/html -type f -name '*.html')
HTML = $(HTML_SRC:src/%.html=dist/%.html)

CLIENT_SRC = $(shell find src/client -type f -name '*.jsx' -or -name '*.js')
CLIENT = dist/client/main.js

SERVER_SRC = $(shell find src/server -type f -name '*.jsx' -or -name '*.js')
SERVER = dist/server/main.js


COMMON_SRC = $(shell find src/common -type f -name '*.jsx' -or -name '*.js')
COMMON = $(COMMON_SRC:src/%.js=dist/%.js) $(COMMON_SRC:src/%.jsx=dist/%.js)

GOSRC = src/main.go
GOBIN = bin/main

LESSC = ./node_modules/.bin/lessc
WATCHIFY = ./node_modules/.bin/watchify
BROWSERIFY = ./node_modules/.bin/browserify
BABEL = ./node_modules/.bin/babel
NODEMON = ./node_modules/.bin/nodemon
NPM = npm

LESSC_FLAGS = --source-map-map-inline
NPM_FLAGS =
LIB_FLAGS = -r immutable -r blackbird -r xhr-promise
CLIENT_BROWSERIFY_FLAGS = -t babelify --extension=.jsx -x immutable -x blackbird -x xhr-promise --debug
SERVER_BROWSERIFY_FLAGS =

.PHONY: clean reallyclean node-modules bin dist gulp lib vendor run watch watchify watchman go-builder node-builder bin-image dist-image vendor-image image run-image

all: dist

bin: bin/main

dist: server client lib vendor dist/package.json

server: $(SERVER) $(COMMON)

client: $(CLIENT) $(CSS) $(HTML)

dist/package.json: package.json
	@cp $< $@
	cd dist && $(NPM) install --production

$(CLIENT): $(CLIENT_SRC) $(COMMON) node_modules
	@mkdir -p $(@D)
	$(BROWSERIFY) $(CLIENT_BROWSERIFY_FLAGS) -o $@.tmp -- $<
	@mv $@.tmp $@

watch:
	@fswatch src | xargs -n1 -I {} sh -c 'make dist && afplay /System/Library/Sounds/Pop.aiff || afplay /System/Library/Sounds/Basso.aiff'

node_modules:
	$(NPM) $(NPM_FLAGS) install

dist/%.js: src/%.js $(BABEL)
	@mkdir -p $(@D)
	$(BABEL) -o $@ $<

dist/%.js: src/%.jsx $(BABEL)
	@mkdir -p $(@D)
	$(BABEL) -o $@ $<

dist/%.css: src/%.less  $(LESSC)
	@mkdir -p $(@D)
	$(LESSC) $(LESSC_FLAGS) $< $@

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
	cd dist && $(NODEMON) --watch server --watch common server/main.js

run-go: dist bin
	@bin/main

$(LESSC) $(WATCHIFY) $(BROWSERIFY) $(BABEL) $(NODEMON): node_modules

go-builder:
	docker build -t go-builder -f docker/go-builder.docker .

node-builder:
	docker build -t node-builder -f docker/node-builder.docker .

bin-image: go-builder
	@mkdir -p $(@D)
	docker run --rm -it -v $(PWD):/go go-builder make bin

dist-image: node-builder
	@mkdir -p $(@D)

vendor-image: vendor
	@mkdir -p $(@D)

go-image: vendor-image dist-image bin-image
	docker build -t $(IMAGE) -f docker/go.docker .

node-image: node-builder
	docker run --rm -it -v $(PWD):/src node-builder make node_modules dist
	docker build -t $(IMAGE) -f docker/node.docker .

run-image:
	docker run --rm -it -p 5000:5000 $(IMAGE)
