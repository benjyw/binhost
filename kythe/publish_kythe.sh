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

VERSION=$1
if [ -z "$VERSION" ];
then
  echo "Usage: $0 <kythe_version> (e.g., kythe-vXX.YY.ZZ.5-snowchainNNN-HHHHHHHHHHH)"
  exit 1
fi

echo "publishing ${VERSION} to binhost"

KYTHE_RELEASES_DIR="${HOME}/kythe_releases"
KYTHE_VERSION_DIR="${KYTHE_RELEASES_DIR}/${VERSION}"

OUTPUT_DIR="kythe/${VERSION}/default"
mkdir -p ${OUTPUT_DIR}

cp "${KYTHE_VERSION_DIR}/extractors/javac_extractor.jar" ${OUTPUT_DIR}
cp "${KYTHE_VERSION_DIR}/indexers/java_indexer.jar" ${OUTPUT_DIR}

git add --all
git commit -m "${VERSION}"
