#!/bin/bash
##  ------------------------------------------------------------------------  ##
##                Build docker image from provided Dockerfile                 ##
##  ------------------------------------------------------------------------  ##
printf "\n\t---------------------\t BOF: $0 $1 \t---------------------------\n";

set -e
trap 'echo >&2 Ctrl+C captured, exiting; exit 1' SIGINT

##  ------------------------------------------------------------------------  ##
##                              PREREQUISITES                                 ##
##  ------------------------------------------------------------------------  ##

WD="$(cd $(dirname $0)/.. && pwd -P)"
ENVD="${WD}/envs"
OPTS=$@

echo "OPTS = [${OPTS}]"

for fe in .env.hub .env
    do
        ENVF="${ENVD}/${fe}"
        #printf "CHECK ENVIRONMENT FILE [${ENVF}]\n";
        if [ -f "${ENVF}" ]; then
           . "${ENVF}";
           printf "ENV: exported vars from [${ENVF}]:\n";
           cat ${ENVF} | sed -e "s/^/\t/g"
        fi
    done

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
    COM_BUILD_IMAGE="docker -D    \
      --log-level=debug \
      build \
      --disable-content-trust=true          \
      --build-arg BUILD_DATE=${BUILD_DATE}  \
      --build-arg VERSION=${NODE_VERSION}   \
      --build-arg VCS_URL=${VCS_URL}        \
      --build-arg VCS_REF=${VCS_REF}        \
      -f Dockerfile                         \
      -t ${Image}:${TAG}                    \
      . "

    printf "\tCOM_BUILD_IMAGE = [${COM_BUILD_IMAGE}]\n";
    #BUILD_IMAGE_ID=$(${COM_BUILD_IMAGE})
    ${COM_BUILD_IMAGE}
    BUILD_IMAGE_ID=$?
    printf "\tBUILD_IMAGE_ID = ${BUILD_IMAGE_ID}\n";
}
#      --pull                                \
#      --force-rm                            \


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

#[[ -n "$1" ]] || usage

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

    *)
        RETVAL=1
    ;;
esac

printf "\n\n[LOG]\tALL DONE\n"
printf "\n\t-------------------------\t EOF: $0 $1 \t----------------------------\n";

exit $RETVAL

