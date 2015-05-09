#!/bin/bash

set -e

function init() {
  FULL_VERSION="1.8.7-2012.02"
  FULL_NAME="ruby-enterprise-${FULL_VERSION}"
  TEMP_DIR=$(mktemp -d)

  echo "Serving from ${TEMP_DIR}"

  cd /tmp

  python -m SimpleHTTPServer $PORT &
}

function download_and_patch() {
  init

  cd $TEMP_DIR
  curl https://rubyenterpriseedition.googlecode.com/files/${FULL_NAME}.tar.gz -s -o - | tar zxf -
  cd $FULL_NAME/source
  curl -o 34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch https://github.com/Genius/rubyenterpriseedition187-330/commit/34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch
  curl -o 5384967a015be227e16af7a332a50d45e14ed0ad.patch https://github.com/Genius/rubyenterpriseedition187-330/commit/5384967a015be227e16af7a332a50d45e14ed0ad.patch
  curl -o tcmalloc_declare_memalign_volatile.patch https://raw.githubusercontent.com/Genius/rubyenterpriseedition187-330/master/patches/tcmalloc_declare_memalign_volatile.patch
  patch -p1 < 34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch
  patch -p1 < 5384967a015be227e16af7a332a50d45e14ed0ad.patch
  patch -p1 < tcmalloc_declare_memalign_volatile.patch
}

function run_installer() {
  DIRECTORY=$1
  OUTPUT=$2

  download_and_patch

  if [ -e $DIRECTORY ]; then
    echo "Output directory ${DIRECTORY} already exists. Removing."
    rm -rf $DIRECTORY
  fi

  cd $TEMP_DIR/$FULL_NAME

  ./installer --auto $DIRECTORY --no-dev-docs --no-tcmalloc

  tar czvf /tmp/${OUTPUT}.tar.gz $DIRECTORY
}

function listen_and_serve() {
  while true
  do
    sleep 60
    echo "Still serving."
  done
}

run_installer /app/vendor/ruby-1.8.7 ruby-1.8.7
run_installer /tmp/ruby-1.8.7 ruby-build-1.8.7

listen_and_serve
