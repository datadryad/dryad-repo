#!/bin/sh

sudo mkdir -p -m 0755 /opt/dryad-test
sudo chown -R $USER /opt/dryad-test
cp -L -r $TRAVIS_BUILD_DIR/test/config /opt/dryad-test/config
cp -r $TRAVIS_BUILD_DIR/dspace-api/src/test/resources/dspaceFolder/testData /opt/dryad-test/
ls -l /opt/dryad-test/config