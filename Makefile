.PHONY: test dependencies

test:
	cd rewrite && make test

dependencies:
	cd rewrite && make dependencies
