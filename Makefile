.PHONY: dependencies

jquery_version = 1.8

download = \
	curl --output $(1) --time-cond $(1) --remote-time $(2); echo

dependencies:
	mkdir -p lib
	$(call download, "lib/jquery.js", \
		"http://ajax.googleapis.com/ajax/libs/jquery/$(jquery_version)/jquery.min.js")
	$(call download, "lib/d3.js", "http://d3js.org/d3.v2.js")
	$(call download, "lib/d3_fisheye.js", \
		"https://raw.github.com/d3/d3-plugins/master/fisheye/fisheye.js")
	$(call download, "lib/rdfquery-core.js", \
		"http://rdfquery.googlecode.com/files/jquery.rdfquery.core.min-1.0.js")
