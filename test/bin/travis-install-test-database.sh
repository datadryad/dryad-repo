#!/bin/sh
# 
# psql -U postgres -c "create user dryad_test_user with createdb;"
# createdb -U dryad_test_user dryad_test

# export PGPORT={{ dryad.testdb.port }}
# Drop the dryad_test database
# dropdb/createdb require PGPASSWORD
#export PGPASSWORD=`grep $PGUSER $HOME/.pgpass | awk -F ':' '{print $5}'`

# Load database schema
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/database_schema.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/database_create_doi_table.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/database_change_payment_system.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/database_terms_and_condition.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/collection-workflow-changes.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/atmire-versioning-changes.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/database_dryad_groups_collections.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/database_dryad_registries.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/dryad-rest-webapp.sql
psql < ${DRYAD_CODE_DIR}/test/etc/postgres/test-system-curator.sql
psql < ${DRYAD_CODE_DIR}/dspace/etc/postgres/update-sequences.sql
psql < ${DRYAD_CODE_DIR}/test/etc/postgres/test-journal-landing.sql

