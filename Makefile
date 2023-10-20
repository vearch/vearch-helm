# vearch-helm Makefile 

all: build

lint:
	helm lint ./charts

build: lint
	helm package ./charts

.PHONY: all lint build
