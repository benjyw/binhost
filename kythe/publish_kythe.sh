#!/usr/bin/env bash

# Note: Run this from the binhost repo root.

# Since Kythe currently does not do regular releases, and in any case doesn't publish their
# releases, we build and publish our own, under custom version numbers.
#
# To create a kythe release in ~/kythe_releases/ to publish:
#
# - Install Bazel from homebrew.
# - Clone https://github.com/google/kythe
# - in your clone:
#   - `tools/modules/update.sh`
#   - `bazel build kythe/release`
#   - `tar xfz bazel-genfiles/kythe/release/kythe-vXX.YY.ZZ.tar.gz -C ~/kythe_releases/`
#     where XX.YY.ZZ is the version of the most recent official Kythe release (0.0.26 at the time of writing).
# - Give the release a custom version, e.g.,:
# - `mv ~/kythe_releases/kythe-vXX.YY.ZZ ~/kythe_releases/kythe-vXX.YY.ZZ.5-snowchainNNN-HHHHHHHHHHH`
#   Where NNN is some running count, and HHHHHHHHHHH is the prefix of the git sha in the Kythe repo
#   at which we built the release (we currently take 11 digits).

set -e

REV=$1
if [ -z "$REV" ];
then
  echo "Usage: $0 <kythe_version> (e.g., vXX.YY.ZZ.5-snowchainNNN-HHHHHHHHHHH)"
  exit 1
fi

echo "publishing ${REV} to binhost"

KYTHE_REV_DIR="${HOME}/kythe_releases/kythe-${REV}"

OUTPUT_DIR="kythe/${REV}"
mkdir -p ${OUTPUT_DIR}

function copy() {
  local SRC="$1"
  local ARTIFACT=$(basename "$1")
  local OUTPUT_DIR="kythe/${ARTIFACT}/${REV}"
  mkdir -p ${OUTPUT_DIR}
  cp "${KYTHE_REV_DIR}/${SRC}.jar" "${OUTPUT_DIR}/${ARTIFACT}-${REV}.jar"
}

copy "extractors/javac_extractor"
copy "indexers/java_indexer"

git add --all
git commit -m "Kythe release ${REV}"
