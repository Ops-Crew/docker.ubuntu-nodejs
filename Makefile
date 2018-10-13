##  ------------------------------------------------------------------------  ##
##                           Build Docker Image                               ##
##  ------------------------------------------------------------------------  ##

.SILENT:
.EXPORT_ALL_VARIABLES:
.IGNORE:
.ONESHELL:

include ./envs/.env*

##  ------------------------------------------------------------------------  ##
##                              PREREQUISITES                                 ##
##  ------------------------------------------------------------------------  ##

# Image can be overidden with env vars
DOCKER_IMAGE ?= $(HUB_USER)/$(HUB_REPO)

# Get the latest commit
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# Get the version number from the code
CODE_VERSION = $(strip $(shell cat VERSION))

# Get the Repo URL and latest commit.
VCS_URL = $(strip $(shell git config --get remote.origin.url))
VCS_REF = $(strip $(shell git rev-parse --short HEAD))

WD := $(shell pwd -P)
DT = $(shell date +'%Y%m%d%H%M%S')
BUILD_DATE = $(strip $(shell date -u +"%Y-%m-%dT%H:%M:%SZ"))

##  ------------------------------------------------------------------------  ##
# Query the default goal.

ifeq ($(.DEFAULT_GOAL),)
.DEFAULT_GOAL := default
endif

##  ------------------------------------------------------------------------  ##
##                                  INCLUDES                                  ##
##  ------------------------------------------------------------------------  ##

include ./bin/*.mk

##  ------------------------------------------------------------------------  ##

default: test

# Build Docker image
build: docker_build output

# Build and push Docker image
release: docker_build docker_push output

# Push image to docker hub as 'latest'
release_latest: docker_push_latest output

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# If we're releasing to Docker Hub, and we're going to mark it with the latest tag, it should exactly match a version release
ifeq ($(MAKECMDGOALS),release)
# Use the version number as the release tag
DOCKER_TAG = v$(NODE_VERSION)

ifndef CODE_VERSION
$(error You need to create a VERSION file to build a release)
endif

# See what commit is tagged to match the version
VERSION_COMMIT = $(strip $(shell git rev-list $(GIT_COMMIT) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(VERSION_COMMIT))
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
# Add the commit ref for development builds. Mark as dirty if the working directory isn't clean
DOCKER_TAG = $(NODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

##  ------------------------------------------------------------------------  ##

test: output banner state

docker_build:
	# Build Docker image
	sudo docker 	-D                         \
					--log-level=debug                \
		build                                  \
			--disable-content-trust=true         \
		  --build-arg BUILD_DATE=$(BUILD_DATE) \
		  --build-arg VERSION=$(CODE_VERSION)  \
			--build-arg VCS_REF=$(VCS_REF)       \
		  --build-arg VCS_URL=$(VCS_URL)       \
		  --build-arg NODE_VERSION=$(NODE_VERSION) \
		  --build-arg SVC_USER=$(SVC_USER)     \
			-f Dockerfile                        \
			-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Push to DockerHub
	sudo docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

docker_push_latest:
	# Tag image as latest
	sudo docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

	# Push to DockerHub
	sudo docker push $(DOCKER_IMAGE):latest

output:
	@ echo ${BYellow}Docker Image${NC}: ${BPurple}$(DOCKER_IMAGE):$(DOCKER_TAG)${NC}
	@ sudo docker inspect $(DOCKER_IMAGE):$(DOCKER_TAG) 2>&1 ;
