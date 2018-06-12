#!/usr/bin/env bash

# Note: Run this from the binhost repo root.

# Since Kythe currently does not do regular releases, and in any case doesn't publish their
# releases, we build and publish our own, under custom version numbers.
#
# See README.md for how to run this script.

set -e

KYTHE_REPO="../kythe"
KYTHE_RELEASES="${HOME}/kythe_releases"

mkdir -p ${KYTHE_RELEASES}

function in_kythe_repo() {
  pushd ${KYTHE_REPO} >> /dev/null
  eval ${1}
  popd >> /dev/null
}

# Get the latest offical kythe release semver.
latest_kythe_release=$(in_kythe_repo "git tag --sort=v:refname | egrep '^v[0-9]' | tail -n 1")
echo "Latest official Kythe release: ${latest_kythe_release}"

# Get the most recent published release.
latest_published_release=`ls kythe/java_indexer/ | grep "${latest_kythe_release}*" | tail -n 1`
custom_release_parts_arr=(${latest_published_release//-/ })
prev_custom_release_version=`echo ${custom_release_parts_arr[1]} | egrep -o '[0-9]+'`
custom_release_version=`printf "%03d" $((10#$prev_custom_release_version + 1))`

echo "Latest custom Kythe release within that official release: ${latest_published_release}"

current_kythe_sha=$(in_kythe_repo "git rev-parse HEAD")
current_kythe_rev=${current_kythe_sha:0:12}

echo "Current Kythe rev: ${current_kythe_rev}"

custom_kythe_release="${latest_kythe_release}-toolchain${custom_release_version}-${current_kythe_rev}"
echo "New custom Kythe release: ${custom_kythe_release}"

echo "Building Kythe at ${current_kythe_rev}"
in_kythe_repo "./tools/modules/update.sh && bazel build kythe/release"

custom_kythe_release_tarball="${KYTHE_RELEASES}/kythe-${custom_kythe_release}.tar.gz"
custom_kythe_release_dir="${KYTHE_RELEASES}/kythe-${custom_kythe_release}"

mv "${KYTHE_REPO}/bazel-genfiles/kythe/release/kythe-${latest_kythe_release}.tar.gz" "${custom_kythe_release_tarball}"
tar xfz ${custom_kythe_release_tarball} -C ${KYTHE_RELEASES}
mv ${KYTHE_RELEASES}/kythe-${latest_kythe_release} ${custom_kythe_release_dir}

echo "Built local custom kythe release at ${custom_kythe_release_dir}"

echo "Run ./kythe/publish_kythe.sh ${custom_kythe_release} and git push origin master to publish externally."