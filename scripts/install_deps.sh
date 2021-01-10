#!/usr/bin/env sh

export VERSION=v4.3.1
export BINARY=yq_linux_amd64

wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz
sudo mv ${BINARY} /usr/bin/yq

export version=v1.1.1
mkdir cr
wget https://github.com/helm/chart-releaser/releases/download/$version/chart-releaser_${version#v}_linux_amd64.tar.gz -O - | tar xz -C cr
sudo mv cr/cr /usr/bin/

rm -rf cr
