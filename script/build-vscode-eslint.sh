#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TAG=release/3.0.16

set -x

# prepare
mkdir -p $DIR/../tmp
mkdir -p $DIR/../dist

cd $DIR/../tmp
if [[ ! -d $DIR/../tmp/vscode-eslint ]]; then
  # clone
  git clone --depth=1 --branch $TAG https://github.com/Microsoft/vscode-eslint vscode-eslint

  # pull
  cd $DIR/../tmp/vscode-eslint
  git clean -fd
  git checkout .
  git pull --rebase
else
  cd $DIR/../tmp/vscode-eslint
  git fetch origin --depth=1 $TAG
  git checkout .
  git checkout $TAG
fi

# npm install
cd $DIR/../tmp/vscode-eslint
yarn --ignore-scripts
yarn
yarn compile

# copy to dist
cd $DIR/..

mkdir -p ./dist/eslint-language-server
cp -r ./tmp/vscode-eslint/server/out/* ./dist/eslint-language-server/
npx babel ./dist/eslint-language-server --out-dir ./lib/eslint-language-server/

