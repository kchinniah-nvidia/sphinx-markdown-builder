# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINX_OPTS      ?=
SPHINX_BUILD     ?= sphinx-build
TESTS_DIR         = tests
SOURCE_DIR        = $(TESTS_DIR)/source
BUILD_DIR         = $(TESTS_DIR)/docs-build
EXPECTED_DIR      = $(TESTS_DIR)/expected

.PHONY: help clean test meld release

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINX_BUILD) -M help "$(SOURCE_DIR)" "$(BUILD_DIR)" $(SPHINX_OPTS) $(O)


clean:
	rm -rf "$(BUILD_DIR)" "$(SOURCE_DIR)/library"


# Catch-all target: route all unknown targets to Sphinx using the new "make mode" option.
# $(O) is meant as a shortcut for $(SPHINX_OPTS).
doc-%:
	@$(SPHINX_BUILD) -M $* "$(SOURCE_DIR)" "$(BUILD_DIR)" $(SPHINX_OPTS) $(O)


docs: doc-markdown


test:
	@# Build http first, then direct because we only care about the index file of the direct tests
	@$(SPHINX_BUILD) -M markdown "$(SOURCE_DIR)" "$(BUILD_DIR)/http" $(SPHINX_OPTS) $(O) -a \
			-D markdown_http_base="https://localhost" -D markdown_uri_doc_suffix=".html"
	@$(SPHINX_BUILD) -M markdown "$(SOURCE_DIR)" "$(BUILD_DIR)/direct" $(SPHINX_OPTS) $(O) -a -t Partners
	cp "$(BUILD_DIR)/http/markdown/auto-summery.md" "$(BUILD_DIR)/direct/markdown/http-auto-summery.md"
	diff --recursive "$(BUILD_DIR)/direct/markdown" "$(EXPECTED_DIR)"


meld:
	meld "$(BUILD_DIR)/direct/markdown" "$(EXPECTED_DIR)" &


release:
	@rm -rf dist/*
	python3 -m build || exit
	python3 -m twine upload --repository sphinx_markdown_builder dist/*
