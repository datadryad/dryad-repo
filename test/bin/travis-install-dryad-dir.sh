#!/bin/sh

sudo mkdir -p -m 0755 /opt/dryad
sudo mkdir -p -m 0755 /opt/dryad/test
sudo mkdir -p -m 0755 /opt/dryad/test/testData
sudo mkdir -p -m 0755 /opt/dryad/test/assetstore
sudo chown -R $USER /opt/dryad
cp -L -r $TRAVIS_BUILD_DIR/test/config /opt/dryad/config
cp -R $TRAVIS_BUILD_DIR/dspace-api/src/test/resources/dspaceFolder/testData/* /opt/dryad/test/testData/
cp $TRAVIS_BUILD_DIR/dspace/etc/server/settings.xml $HOME/.m2/
ls -lR /opt/dryad/test
