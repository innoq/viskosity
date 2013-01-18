.PHONY: test lint dependencies clean

jquery_version = 1.8
qunit_version = 1.10.0

download = \
	curl --output $(1) --time-cond $(1) --remote-time $(2); echo

test:
	@phantomjs lib/phantomjs-qunit-runner.js test/index.html | \
			 sed -e "s/[^0 ][^0 ]* failed/\x1b[31m&\x1b[0m/" \
					-e  "s/Failed assertion: expected: \(.*\), but was: \(.*\)/\n    assertion failed\n    \x1b[31;1mexpected: \1\x1b[0m\n    \x1b[32;1mactual  : \2\x1b[0m/"

dependencies:
	mkdir -p lib
	$(call download, "lib/d3.js", "http://d3js.org/d3.v3.min.js")
	$(call download, "lib/jquery.js", \
		"http://ajax.googleapis.com/ajax/libs/jquery/$(jquery_version)/jquery.min.js")
	# dev-only
	$(call download, "lib/mockjax.js", \
		"https://raw.github.com/appendto/jquery-mockjax/master/jquery.mockjax.js")
	$(call download, "lib/qunit.js", \
		"http://code.jquery.com/qunit/qunit-$(qunit_version).js")
	$(call download, "lib/qunit.css", \
		"http://code.jquery.com/qunit/qunit-$(qunit_version).css")
	$(call download, "lib/blanket.js", \
		"https://raw.github.com/Migrii/blanket/master/dist/qunit/blanket.min.js")
	$(call download, "lib/phantomjs-qunit-runner.js", \
		"https://raw.github.com/jquery/qunit/master/addons/phantomjs/runner.js")

clean:
	find {scripts,test} -name "*.js" | xargs rm || true
