SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Set application-specific parameters
NAME ?= ErlangInstaller
VERSION ?= 1.0.2

SOURCE_DIR ?= src
SOURCE_FILES ?= ErlangInstaller.app

TEMPLATE_DMG ?= $(SELF_DIR)template.dmg

# Include the master makefile
include $(SELF_DIR)fancy-dmg.mk