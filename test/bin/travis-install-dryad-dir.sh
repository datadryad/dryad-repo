#!/bin/sh

sudo mkdir -p -m 0755 /opt/dryad
sudo chown -R $USER /opt/dryad
cp -L -r $TRAVIS_BUILD_DIR/test/config /opt/dryad/config
cp $TRAVIS_BUILD_DIR/dspace/etc/server/settings.xml $HOME/.m2/
