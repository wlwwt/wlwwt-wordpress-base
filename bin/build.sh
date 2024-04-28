#!/bin/bash

set -euo pipefail

REPO=https://github.com/wlwwt/seo-producer-python
BRANCH=main
TOKEN=

CLEANUP_ITEMS=(
  ".ddev/"
  "ansible/"
  "bin/build.sh"
  "bin/sync"
  "bin/wp"
  "bin/wp.bat"
  "var/"
  "public/wp-config.development.php"
  ".editorconfig"
  ".gitignore"
  "composer.json"
  "composer.lock"
  "README.md")

# FUNCTIONS

function build() {

  echo "--- Build START ---"

  rm -rf .build

  mkdir -p .build && cd .build || return
  mkdir -p artifact
  mkdir -p dist

  curl -L -k -u token:$TOKEN $REPO/tarball/$BRANCH | (cd artifact && tar -xz --strip-components=1 -)

  echo "##-> Getting project from $REPO in branch $BRANCH"
  cd artifact || return

  echo "##-> Composer install"
  composer install --no-dev

  echo "##-> Removing files and folders"

  for i in "${CLEANUP_ITEMS[@]}"; do
    rm -rf "$i"
  done

  echo "##-> Leaving artifact dir"

  cd ..

  echo "##-> Tar artifact"
  tar -czf dist/artifact.tar.gz -C artifact .

  echo "--- Build END ---"
}

function cleanup() {
  rm -rf .build/
  echo "--- Cleanup DONE ---"
}

# SCRIPT

if [ $# -lt 1 ]; then
  echo "Usage : $0 COMMAND"
  exit
fi

case "$1" in

build)
  build
  ;;
cleanup)
  cleanup
  ;;
*)
  echo "Unknown command"
  ;;
esac
