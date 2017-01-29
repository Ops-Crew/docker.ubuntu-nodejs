#!/bin/bash

set -e

trap 'echo >&2 Ctrl+C captured, exiting; exit 1' SIGINT

image="$1"; shift

docker build --pull                 \
             -t repo-info:local     \
             -q -f Dockerfile.local \
             . > /dev/null

name="repo-info-local-$$-$RANDOM"
trap "docker rm -f '$name-data' '$name' > /dev/null || :" EXIT

docker create           \
    --name "$name-data" \
    -v /etc/apt         \
    -v /usr/share/doc   \
    -v /var/lib/dpkg    \
    "$image"            \
    bogus > /dev/null

docker run -d                           \
           --name "$name"               \
           --volumes-from "$name-data"  \
           repo-info:local > /dev/null

echo '# `'"$image"'`'

docker inspect -f '
## Docker Metadata
- Image ID: `{{ .Id }}`
- Created: `{{ .Created }}`
- Arch: `{{ .Os }}`/`{{ .Architecture }}`
{{ if .Config.Entrypoint }}- Entrypoint: `{{ json .Config.Entrypoint }}`
{{ end }}{{ if .Config.Cmd }}- Command: `{{ json .Config.Cmd }}`
{{ end }}- Environment:{{ range .Config.Env }}{{ "\n" }}  - `{{ . }}`{{ end }}' "$image"

docker logs -f "$name"
