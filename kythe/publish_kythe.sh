#!/usr/bin/env bash

VERSION=$1
if [ -z "$VERSION" ];
then
  echo "Usage: $0 <kythe_version>"
  exit 1
fi

echo "publishing ${VERSION} to binhost"

EXTRACTOR_REL_DIR="${VERSION}/extractors"
INDEXER_REL_DIR="${VERSION}/indexers"
mkdir -p ${EXTRACTOR_REL_DIR}
mkdir -p ${INDEXER_REL_DIR}

KYTHE_RELEASES_DIR="${HOME}/kythe_releases"

cp "${KYTHE_RELEASES_DIR}/${EXTRACTOR_REL_DIR}/javac_extractor.jar" ${EXTRACTOR_REL_DIR}
cp "${KYTHE_RELEASES_DIR}/${INDEXER_REL_DIR}/java_indexer.jar" ${INDEXER_REL_DIR}

git add --all
git commit -m "${VERSION}"
