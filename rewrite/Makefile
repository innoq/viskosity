.PHONY: test lint dependencies

qunit_version = 1.10.0

download = \
	curl --output $(1) --time-cond $(1) --remote-time $(2); echo

test:
	phantomjs lib/phantomjs-qunit-runner.js test/index.html || \
			echo -e '\033[31mfailing tests\033[0m'

dependencies:
	mkdir -p lib
	$(call download, "lib/qunit.js", \
		"http://code.jquery.com/qunit/qunit-$(qunit_version).js")
	$(call download, "lib/qunit.css", \
		"http://code.jquery.com/qunit/qunit-$(qunit_version).css")
	$(call download, "lib/phantomjs-qunit-runner.js", \
		"https://raw.github.com/jquery/qunit/master/addons/phantomjs/runner.js")
