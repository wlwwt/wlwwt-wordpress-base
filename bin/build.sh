#!/bin/bash

set -euo pipefail

REPO=---project-repository---
BRANCH=main

CLEANUP_ITEMS=(
  ".ddev/"
  "ansible/"
  "bin/build.sh"
  "bin/doctrine-dbal"
  "bin/fluid"
  "bin/php-cs-fixer"
  "bin/php-parse"
  "bin/phpstan"
  "bin/phpstan.phar"
  "bin/pscss"
  "bin/replace_symlink.sh"
  "bin/sync"
  "bin/t3-cs"
  "bin/typo3-coding-standards"
  "bin/var-dump-server"
  "bin/yaml-lint"
  "boilerplate/"
  "extensions/"
  "var/"
  "public/.htaccess_development"
  ".editorconfig"
  ".env.development"
  ".gitignore"
  ".php-cs-fixer.dist.php"
  "bitbucket-pipelines.yml"
  "composer.json"
  "composer.lock"
  "phpstan.neon"
  "README.md")

# FUNCTIONS

function build() {

  echo "--- Build START ---"

  rm -rf .build

  mkdir -p .build && cd .build || return
  mkdir -p artifact
  mkdir -p dist

  git archive --format=tar --remote=$REPO $BRANCH | (cd artifact && tar xf -)

  echo "##-> Getting project from $REPO in branch $BRANCH"
  cd artifact || return

  echo "##-> Composer install"
  composer install --no-dev

  echo "##-> Dropping linked extensions from web/typo3conf/ext"
  find vendor/communiacs -type l -exec ../../bin/replace_symlink.sh {} +

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
