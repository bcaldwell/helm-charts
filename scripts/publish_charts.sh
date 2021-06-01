#!/usr/bin/env bash

# losely based on https://github.com/helm/chart-releaser-action/blob/master/cr.sh

set -o errexit
set -o nounset
set -o pipefail

main() {
    local charts_dir=charts
    local owner=${OWNER}
    local repo=${REPO}
    local charts_repo_url=${CHART_REPO_URL}

    : "${GITHUB_TOKEN:?Environment variable GITHUB_TOKEN must be set}"
    export CR_TOKEN=$GITHUB_TOKEN

    local repo_root
    repo_root=$(git rev-parse --show-toplevel)
    pushd "$repo_root" > /dev/null

    echo 'Looking up latest tag...'
    local latest_tag
    latest_tag=$(lookup_latest_tag)

    echo "Discovering changed charts since '$latest_tag'..."
    local changed_charts=()
    readarray -t changed_charts <<< "$(lookup_changed_charts "$latest_tag")"

    if [[ -n "${changed_charts[*]}" ]]; then
        rm -rf .cr-release-packages
        mkdir -p .cr-release-packages

        rm -rf .cr-index
        mkdir -p .cr-index

        for chart in "${changed_charts[@]}"; do
            if [[ -d "$chart" ]]; then
                package_chart "$chart"
            else
                echo "Chart '$chart' no longer exists in repo. Skipping it..."
            fi
        done

        release_charts
        update_index
    else
        echo "Nothing to do. No chart changes detected."
    fi

    popd > /dev/null
}

lookup_latest_tag() {
    git fetch --tags > /dev/null 2>&1

    if ! git describe --tags --abbrev=0 2> /dev/null; then
#         git rev-list --max-parents=0 --first-parent HEAD
         git rev-list -n 1 $(git describe --tags --abbrev=0)
    fi
}

filter_charts() {
    while read -r chart; do
        [[ ! -d "$chart" ]] && continue
        local file="$chart/Chart.yaml"
        if [[ -f "$file" ]]; then
            echo "$chart"
        else
           echo "WARNING: $file is missing, assuming that '$chart' is not a Helm chart. Skipping." 1>&2
        fi
    done
}

lookup_changed_charts() {
    local commit="$1"

    local changed_files
    changed_files=$(git diff --find-renames --name-only "$commit" -- "$charts_dir")

    local depth=$(( $(tr "/" "\n" <<< "$charts_dir" | wc -l) + 1 ))
    local fields="1-${depth}"

    cut -d '/' -f "$fields" <<< "$changed_files" | uniq | filter_charts
}

package_chart() {
    local chart="$1"

    local args=("$chart" --package-path .cr-release-packages)

    echo "Packaging chart '$chart'..."
    cr package "${args[@]}"
}

release_charts() {
    local args=(-o "$owner" -r "$repo" -c "$(git rev-parse HEAD)")

    echo 'Releasing charts...'
    cr upload "${args[@]}"
}

update_index() {
    local args=(-o "$owner" -r "$repo" -c "$charts_repo_url" --push)

    echo 'Updating charts repo index...'
    cr index "${args[@]}"
}

main
