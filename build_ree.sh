#!/bin/bash

set -e

function init() {
  FULL_VERSION="1.8.7-2012.02"
  FULL_NAME="ruby-enterprise-${FULL_VERSION}"
  TEMP_DIR=$(mktemp -d)

  echo "Serving from /tmp"

  cd /tmp

  python -m SimpleHTTPServer $PORT &
}

function download_and_patch() {
  init

  cd $TEMP_DIR
  curl https://rubyenterpriseedition.googlecode.com/files/${FULL_NAME}.tar.gz -s -o - | tar zxf -
  cd $FULL_NAME/source
  patch -p1 < /app/patches/34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch
  patch -p1 < /app/patches/5384967a015be227e16af7a332a50d45e14ed0ad.patch
  patch -p1 < /app/patches/CVE-2015-1855.patch
  patch -p1 < /app/patches/tcmalloc_declare_memalign_volatile.patch
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

  export CFLAGS="-O2 -fno-tree-dce -fno-optimize-sibling-calls"
  ./installer --auto $DIRECTORY --no-dev-docs --dont-install-useful-gems --no-tcmalloc

  cd $DIRECTORY && {
    tar czvf /tmp/${OUTPUT}.tgz .
  }
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
