#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

local VERSION=v4.2.0
local BINARY=yq_linux_amd64

apk update
apk add openssh-client git bash

wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
  tar xz && mv ${BINARY} /usr/bin/yq
