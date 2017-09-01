#!/usr/bin/env bash

# Note: Run this from the binhost repo root.

# Since Kythe currently does not do regular releases, and in any case doesn't publish their
# releases, we build and publish our own, under custom version numbers.
#
# See README.md for how to run this script.

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
