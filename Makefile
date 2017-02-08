# $@ = target file
# $< = first dependency
# $^ = all dependencies

TESTS = test/*.test.js
REPORTER = spec
TIMEOUT = 20000
ISTANBUL = ./node_modules/.bin/istanbul
MOCHA = ./node_modules/mocha/bin/_mocha
COVERALLS = ./node_modules/coveralls/bin/coveralls.js
DOXMATE = ./node_modules/.bin/doxmate
BABEL = ./node_modules/.bin/babel
PATH := ./node_modules/.bin:$(PATH)

JS_SOURCES = $(wildcard lib/*.es)
OBJ = $(patsubst %.es,%.js, $(JS_SOURCES))

lib/%.js: lib/%.es
	$(BABEL) $< -o $@

lint:
	@eslint --fix lib test

build: ${OBJ} .babelrc

doc:
	@doxmate build -o out

test: build
	@NODE_ENV=test mocha \
		--reporter $(REPORTER) \
		--require co-mocha \
		--timeout $(TIMEOUT) \
		$(MOCHA_OPTS) \
		$(TESTS)

test-debug:
	@NODE_ENV=test mocha -d \
		--reporter $(REPORTER) \
		--require co-mocha \
		--timeout $(TIMEOUT) \
		$(MOCHA_OPTS) \
		$(TESTS)

test-cov:
	@NODE_ENV=test istanbul cover --report html \
		./node_modules/.bin/_mocha -- \
		--reporter $(REPORTER) \
		--require co-mocha \
		--timeout $(TIMEOUT) \
		$(MOCHA_OPTS) \
		$(TESTS)

test-coveralls:
	@istanbul cover --report lcovonly $(MOCHA) -- -t $(TIMEOUT) -R spec $(TESTS)
	@echo TRAVIS_JOB_ID $(TRAVIS_JOB_ID)
	@cat ./coverage/lcov.info | $(COVERALLS) && rm -rf ./coverage

test-all: test test-coveralls

.PHONY: test
