#!/bin/env bash

# use app and type to determine directory
# do not create any folders, except leaf `crds` folder
APP=$1
TYPE=$2
if ! test -d "${TYPE}/${APP}"
then
    echo "${TYPE}/${APP} does not exist" && exit 1
fi
mkdir -p "${TYPE}/${APP}/base/crds"

# handle being given a url filepath or directory
# if url filepath, split documents
# if directory, iterate through file in dir
URL=$3
TMPDIR=$(mktemp -d)

curl -s $URL \
    | yq '
        .spec.versions = (
            [
                .spec.versions[]
                | select(.deprecated != true)
            ]
        )
    ' \
    | yamlfmt -in \
    > "${TMPDIR}/crd.yaml"

pushd $TMPDIR
yq -s '.metadata.name + ".yaml"' crd.yaml
rm crd.yaml
popd

mv "${TMPDIR}"/* "${TYPE}/${APP}/base/crds/"
