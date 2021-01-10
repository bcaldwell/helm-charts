#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -A metadataMapping=(
  ["postgres-s3-backup"]="selfops/postgres-s3-backup"
  ["jupyter"]="jupyter/jupyter"
)

main() {
  : "${GITHUB_TOKEN:?Environment variable GITHUB_TOKEN must be set}"

  local k8s_config_repo="$K8S_CONFIG_REPO"
  local k8s_config_folder=$(mktemp -d)

  git clone $k8s_config_repo $k8s_config_folder

  for chart in "${!metadataMapping[@]}"; do
    echo "processing $chart..."
    local version=$(get_chart_version $chart)
    if [ ! -z $version ]; then
      echo "latest version of $chart is $version"
      update_metadata_file $k8s_config_folder ${metadataMapping[$chart]} $version
    fi
  done

  push_changes $k8s_config_folder
}

get_chart_version() {
  local file="charts/$1/Chart.yaml"
  if [[ -f "$file" ]]; then
      yq e '.version' $file
      return $?
  else
     echo "SKIPPING: $file is missing, assuming that '$chart' is not a Helm chart." 1>&2
     return 1
  fi
}

update_metadata_file() {
  local file="$1/$2/metadata.yml"

  if [[ -f "$file" ]]; then
    echo "updating $file"
    local expression='.helm.version="'"$3"'"'
    yq e -i $expression $file
    cat $file
  else
     echo "SKIPPING: $file is missing." 1>&2
  fi
}

push_changes() {
  pushd "$1" > /dev/null

  local msg="update charts: "
  local changed=()

  readarray -t changed <<< $(git diff --name-only)

  git diff --name-only

  len=${#changed[@]}

  if [[ -n "${changed[*]}" ]]; then
    for i in "${!changed[@]}"; do
      msg+=$(dirname ${changed[$i]})
      if [ $i -lt $((len-1)) ] ; then
        msg+=", "
      fi
    done
  fi

  git add .
  git commit -m "$msg"
  git push
}

main
