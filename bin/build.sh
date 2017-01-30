#!/bin/bash
##  ------------------------------------------------------------------------  ##
##                Build docker image from provided Dockerfile                 ##
##  ------------------------------------------------------------------------  ##

set -e
trap 'echo >&2 Ctrl+C captured, exiting; exit 1' SIGINT
cd $(dirname $0)/..

##  ------------------------------------------------------------------------  ##
##                              PREREQUISITES                                 ##
##  ------------------------------------------------------------------------  ##
for fe in .env.hub .env
    do
        if [ -f "${fe}" ]; then
           . "${fe}";
           printf "SOURCE FROM: ${fe}\n";
        fi
    done

Image="$1"; shift

D="$(date +"%Y%m%d")"
DATE="$(date +"%Y%m%d%H%M%S")"
DATETIME="$(date "+%Y-%m-%d")_$(date "+%H-%M-%S")"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get the Repo URL and latest commit.
VCS_URL="https://$(git config --get remote.origin.url | cut -d@ -f2 | tr -s \":\" \"/\")"
VCS_REF="$(git rev-parse --short HEAD)"

NODE_VERSION=${NODE_VERSION:-7.4.0}
TAG="v${NODE_VERSION}"
HUB_IMAGE=${HUB_USER}/${HUB_REPO}

printf "\n------------------------------  ${DATE}  ------------------------------\n";

function dockerBuild () {
    printf "\t$0 params: \t [$@]\n";
    Image=$1;
    if [ "$1" == "" ]; then
        Image=${HUB_IMAGE}
    fi
    printf "\tBuild Image = \t [$Image]\n\n";

    ##  Build Docker image
    COM_BUILD_IMAGE="docker -D build        \
      --force-rm                            \
      --pull                                \
      --disable-content-trust=true          \
      --build-arg BUILD_DATE=${BUILD_DATE}  \
      --build-arg VERSION=${NODE_VERSION}   \
      --build-arg VCS_URL=${VCS_URL}        \
      --build-arg VCS_REF=${VCS_REF}        \
      -f Dockerfile                         \
      -t ${Image}:${TAG}                    \
      . "

    printf "\tCOM_BUILD_IMAGE = [${COM_BUILD_IMAGE}]\n";
    BUILD_IMAGE_ID=$(${COM_BUILD_IMAGE})
}


##  ------------------------------------------------------------------------  ##
##                                    LOGGER                                  ##
##  ------------------------------------------------------------------------  ##
function log {
    printf "DATETIME:\t[${D_T}]\n" > "${APP_LOG}"
    printf "APP_NAME:\t[${APP_NAME}]\n" >> "${APP_LOG}"
    printf "APP_TITLE:\t[${APP_TITLE}]\n" >> "${APP_LOG}"

    tail -10 "${APP_LOG}"
}

function usage () {
    >&2 cat << EOM
Build Docker Image from Dockerfile

Usage: $0 <command> [<params>]

    $0 usage                -   show usage information
    $0 image [<image_id>]   -   build image

EOM
    RETVAL=1
}

[[ -n "$1" ]] || usage

##  ------------------------------------------------------------------------  ##
##                                  EXECUTION                                 ##
##  ------------------------------------------------------------------------  ##
printf "\n\t-------------------------\t $0 $@ \t----------------------------\n";

case "$1" in

    "usage")
        usage
    ;;

    "image" | "img" | "i")
        printf "\tBUILD_IMAGE \t ${BUILD_IMAGE}:${DOCKER_TAG}\n";
        dockerBuild "$2"
        RETVAL=$?
    ;;

    *)
        usage;
        RETVAL=1
    ;;
esac

printf "\n\n[LOG]\tALL DONE\n"
##  ----------------------------  EOF: $0 $@ -------------------------------  ##

exit $RETVAL

