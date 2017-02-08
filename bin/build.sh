#!/bin/bash
##  ------------------------------------------------------------------------  ##
##                               Build Docker Image                           ##
##  ------------------------------------------------------------------------  ##

set -e
trap 'echo >&2 Ctrl+C captured, exiting; exit 1' SIGINT

function usage () {
    >&2 cat << EOM
            ${BWhite}Build Docker Image${NC}

Usage: $0 <command> [<params>]

    $0 usage                    -   show usage information
    $0 <image | i> [<image_id>] -   build image

EOM
    RETVAL=1
}


##  ------------------------------------------------------------------------  ##
##                              PREREQUISITES                                 ##
##  ------------------------------------------------------------------------  ##

WD="$(cd $(dirname $0)/.. && pwd -P)"
BIND="${WD}/bin"
ENVD="${WD}/envs"
OPTS=$@

source ${BIND}/f.sh
loadEnv "${ENVD}"

log "ENVD:\t${ENVD}"
log "OPTS = [${OPTS}]"

##  ------------------------------------------------------------------------  ##
##                                ENVIRONMENT                                 ##
##  ------------------------------------------------------------------------  ##

Image="$2"; # shift

D="$(date +"%Y%m%d")"
DATE="$(date +"%Y%m%d%H%M%S")"
DATETIME="$(date "+%Y-%m-%d")_$(date "+%H-%M-%S")"
BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Get the Repo URL and latest commit.
#VCS_URL="https://$(git config --get remote.origin.url | cut -d@ -f2 | tr -s \":\" \"/\")"
VCS_URL="$(git config --get remote.origin.url)"
VCS_REF="$(git rev-parse --short HEAD)"

#NODE_VERSION=${NODE_VERSION:-7.4.0}
TAG=${NODE_VERSION:-${VCF_REF}}
HUB_IMAGE=${HUB_USER}/${HUB_REPO}

printf "\n------------------------------  ${DATE}  ------------------------------\n";

function dockerBuild () {
    printf "\t$0 params: \t [$@]\n";
    Image=$1;
    if [ "$1" == "" ]; then
        Image=${HUB_IMAGE}
    fi
    printf "\tBuild Image = \t [${Image}]\n\n";

    ##  Build Docker image
    COM_BUILD_IMAGE="docker -D                  \
                            --log-level=debug   \
        build                                   \
          --quiet                               \
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
    echo -e "\t${BWhite}BUILD_IMAGE_ID${NC} = ${BUILD_IMAGE_ID}\n";
    echo ${BUILD_IMAGE_ID} > "BUILD_IMAGE.ID"
}
#      --pull                                \
#      --force-rm                            \


##  ------------------------------------------------------------------------  ##
##                                  EXECUTION                                 ##
##  ------------------------------------------------------------------------  ##
printf "\n\t-------------------------\t $0 $1 \t----------------------------\n";

case "$1" in

    "")
        usage
        RETVAL=1
    ;;

    "usage")
        usage
    ;;

    image | img | i)
        printf "\tBUILD_IMAGE \t ${HUB_IMAGE}:${TAG}\n";
        dockerBuild "$2"
        RETVAL=$?
    ;;

    ii)
        log "\tMETA INFO:" "$@"
        metaInfo "$2"
    ;;

    *)
        RETVAL=1
    ;;

esac

printf "\n\n[LOG]\tALL DONE\n"

exit $RETVAL

