# Convenience Makefile for generating and releasing libswiftnav-python

SWIFTNAV_ROOT := $(shell pwd)
MAKEFLAGS += SWIFTNAV_ROOT=$(SWIFTNAV_ROOT)

.PHONY: help all docs test dist

help:
	@echo
	@echo "Helper for libswiftnav-python."
	@echo
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  help      to display this help message"
	@echo "  all       to make SBP clients across all languages"
	@echo "  dist      to distribute to PyPi"
	@echo "  docs      to make HTML documentation"
	@echo "  test      to run all tests"
	@echo

all: test docs

docs:
	@echo
	@echo "Generating Python documentation..."
	@echo
	cd $(SWIFTNAV_ROOT)/docs/ && make html
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished!"

test:
	@echo "Running tests..."
	@echo
	tox
	@echo
	@echo "Finished!"

dist:
	@echo
	@echo "Currently a NOOP..."
	@echo
