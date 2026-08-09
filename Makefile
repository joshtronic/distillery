.PHONY: test validate build

test:
	bin/test-still.sh

validate:
	bin/still validate

build:
	bin/still build
