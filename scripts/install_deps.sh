#!/usr/bin/env sh

export VERSION=v4.25.3
export BINARY=yq_linux_amd64

wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz
sudo mv ${BINARY} /usr/bin/yq

# stuck on 1.2 due to: https://github.com/helm/chart-releaser/issues/124
export version=v1.2.0
mkdir cr
wget https://github.com/helm/chart-releaser/releases/download/$version/chart-releaser_${version#v}_linux_amd64.tar.gz -O - | tar xz -C cr
sudo mv cr/cr /usr/bin/

rm -rf cr
