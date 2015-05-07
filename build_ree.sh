#!/bin/bash

set -e

FULL_VERSION="1.8.7-2012.02"
FULL_NAME="ruby-enterprise-${FULL_VERSION}"

TEMP_DIR=$(mktemp -d)

cd $TEMP_DIR

rm -rf /tmp/tmp.*

echo "Serving on port $PORT from ${TEMP_DIR}"
cd /tmp

python -m SimpleHTTPServer $PORT &

curl https://rubyenterpriseedition.googlecode.com/files/${FULL_NAME}.tar.gz -s -o - | tar zxf -

cd $FULL_NAME/source
curl -o 34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch https://github.com/Genius/rubyenterpriseedition187-330/commit/34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch
curl -o 5384967a015be227e16af7a332a50d45e14ed0ad.patch https://github.com/Genius/rubyenterpriseedition187-330/commit/5384967a015be227e16af7a332a50d45e14ed0ad.patch
curl -o tcmalloc_declare_memalign_volatile.patch https://raw.githubusercontent.com/Genius/rubyenterpriseedition187-330/master/patches/tcmalloc_declare_memalign_volatile.patch
patch -p1 < 34ba44f94a62c63ddf02a045b6f4edcd6eab4989.patch
patch -p1 < 5384967a015be227e16af7a332a50d45e14ed0ad.patch
patch -p1 < tcmalloc_declare_memalign_volatile.patch

cd ../

./installer --auto $TEMP_DIR/app/vendor/ruby-1.8.7 --no-dev-docs --no-tcmalloc

cd $TEMP_DIR
tar czvf /tmp/$FULL_NAME.tar.gz .

while true
do
  sleep 60
  echo "Still serving."
done
