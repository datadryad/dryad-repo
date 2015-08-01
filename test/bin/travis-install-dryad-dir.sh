#!/bin/sh

export DRYAD_CODE_DIR=.
# Copy test directory to local filesystem, outside of source repo, and owned by dryad user
export DRYAD_TEST_DIR="/opt/dryad/test"


sudo mkdir -p -m 0755 $DRYAD_TEST_DIR
sudo mkdir -p -m 0755 /opt/dryad/test/testData
sudo mkdir -p -m 0755 /opt/dryad/test/assetstore
sudo chown -R $USER /opt/dryad
cp -L -r $TRAVIS_BUILD_DIR/test/config $DRYAD_TEST_DIR/config
cp -R $TRAVIS_BUILD_DIR/dspace-api/src/test/resources/dspaceFolder/testData/* $DRYAD_TEST_DIR/testData/
cp $TRAVIS_BUILD_DIR/dspace/etc/server/settings.xml $HOME/.m2/

# These are needed somehow by bagit ingest tests
cp -p -r "${DRYAD_CODE_DIR}/dspace/config/crosswalks" "${DRYAD_TEST_DIR}/config/"
cp -p -r "${DRYAD_CODE_DIR}/dspace/config/dspace-solr-search.cfg" "${DRYAD_TEST_DIR}/config/"

# Update the testing version of dspace.cfg with database credentials
# Ansible provisioning installs password into .pgpass, so fish it out of there

cat "${DRYAD_CODE_DIR}/dspace/config/dspace.cfg" \
  | sed "s|db.username =.*|db.username = ${PGUSER}|g" \
  | sed "s|dspace.dir = .*|dspace.dir = ${DRYAD_TEST_DIR}|g" \
  | sed "s|doi.service.testmode= .*|doi.service.testmode= true|g" \
  | sed "s|doi.datacite.connected = .*|doi.datacite.connected = false|g" \
  | sed "s|dspace.url = .*|dspace.url = http://localhost:9999|g" \
  | sed "s|db.url = .*|db.url = jdbc:postgresql://127.0.0.1:5432/dryad_test_db|g" \
  | sed "s|db.username = .*|db.username = dryad_test_user|g" \
  | sed "s|db.password = .*|db.password =|g" \
  >"${DRYAD_TEST_DIR}/config/dspace.cfg"
