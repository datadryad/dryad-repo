#!/bin/sh

sudo mkdir -p -m 0755 /opt/dryad-test
sudo cp -L -R $TRAVIS_BUILD_DIR/test/config /opt/dryad-test/config
sudo cp -R $TRAVIS_BUILD_DIR/dspace-api/src/test/resources/dspaceFolder/testData /opt/dryad-test/testData
sudo chown -R $USER /opt/dryad-test
sudo chmod -R 0777 /opt/dryad-test
ls -l /opt/dryad-test/config
