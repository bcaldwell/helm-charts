#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y

local version=v1.1.1
curl -sSLo cr.tar.gz "https://github.com/helm/chart-releaser/releases/download/$version/chart-releaser_${version#v}_linux_amd64.tar.gz"
mkdir cr
tar -xzf cr.tar.gz -C "cr"
mv cr/cr/cr /usr/bin/
rm -rf cr.tar.gz cr
