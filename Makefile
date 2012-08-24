.PHONY: dependencies

jquery_version = 1.8

dependencies:
	mkdir -p lib
	curl -o "lib/jquery.js" \
		"http://ajax.googleapis.com/ajax/libs/jquery/$(jquery_version)/jquery.min.js"
	curl -o "lib/d3.js" "http://d3js.org/d3.v2.min.js"
	curl -o "lib/d3_pack.css" "http://mbostock.github.com/d3/ex/pack.css"
