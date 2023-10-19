# vearch-helm Makefile 

all: build

lint:
	helm lint ./vearch

build: lint
	helm package ./vearch

.PHONY: all lint build
