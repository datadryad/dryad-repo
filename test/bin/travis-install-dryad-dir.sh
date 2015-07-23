#!/bin/sh

sudo mkdir -p -m 0755 /opt/dryad-test
sudo chown -R $USER /opt/dryad-test
echo "copy from: "
ls -la $TRAVIS_BUILD_DIR/test/config
echo "copy to: "
ls -la /opt/dryad-test/config
echo "copying now"
cp -L -r $TRAVIS_BUILD_DIR/test/config /opt/dryad-test/config
ls -la /opt/dryad-test/config