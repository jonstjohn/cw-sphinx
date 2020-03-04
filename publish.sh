#!/usr/bin/env bash

#
# Publish container for a specific tagged version
# The script requires at least the version to be provided
#
# Usage:
# ./publish.sh [version] [tag]
#
# Tag is optional and the version will be usd if not provided
#

ARCHIVE_DIR="archive/"
ARCHIVE_FILE="archive.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR$ARCHIVE_FILE"

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Error: Version is required and should be provided as a command-line argument"
    exit 1
fi

TAG=${2:-$VERSION}

# Check for local teag
echo "> Checking for local tag"

# If local tag does not exist, try to fetch
if [ "$TAG" != "`git tag -l $TAG`" ]; then
  echo "> Fetching remote changes"
  git fetch
  if [ $? -ne 0 ]; then
    echo "Error: Fetch failed. Run \"git fetch\" to see what the issue is and resolve it before running this script again."
    exit 1
  fi
  # If tag does not exist after the fetch then error
  if [ "$TAG" != "`git tag -l $TAG`" ]; then
    echo "Error: The tag $TAG does not exist. First create a tag/release in Gitlab, then re-run the publish script."
    exit 1
  fi
fi

echo
echo "========================================"
echo "Version: $VERSION"
echo "Tag: $TAG"
echo "========================================"
echo

echo
echo "> Exporting to $ARCHIVE_PATH"
echo

git archive -o $ARCHIVE_PATH $TAG

echo
echo "> Extracting $ARCHIVE_PATH"
echo

tar -zxf $ARCHIVE_PATH -C $ARCHIVE_DIR
rm $ARCHIVE_PATH

echo
echo "> Copying config.cfg"
echo

cp config.cfg $ARCHIVE_DIR

echo
echo "> Changing directories to $ARCHIVE_DIR"
echo

cd $ARCHIVE_DIR
pwd

echo
echo "> Building image"
echo

docker build -t jonstjohn/cw-sphinx:$VERSION .

echo
echo "> Tagging image"
echo

docker tag jonstjohn/cw-sphinx:$VERSION gcr.io/api-project-736062072361/cw-sphinx:$VERSION
docker tag jonstjohn/cw-sphinx:$VERSION gcr.io/api-project-736062072361/cw-sphinx

echo
echo "> Publishing image"
echo

docker push gcr.io/api-project-736062072361/cw-sphinx:$VERSION
docker push gcr.io/api-project-736062072361/cw-sphinx

if [ $? -ne 0 ]; then
  echo "Error: Pod publish failed. Resolve the issues mentioned in the output above."
  exit 1
fi

echo
echo "> Image version $VERSION published successfully!"
echo
