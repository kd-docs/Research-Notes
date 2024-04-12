SHELL = /bin/bash

default: all
	xelatex --shell-escape --output-directory=build/ main.tex
	@read -n1 -p "Open it? ([n]/y)" ans ; if [ "$$ans" = "y" ]; then zathura build/thesis.pdf & fi

biber:
	biber build/main

build:
	mkdir -p build

clean:
	rm -rf build

all: build

.PHONY: default all clean biber
