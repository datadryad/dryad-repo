#!/bin/sh
# 
# psql -U postgres -c "create user dryad_test_user with createdb;"
# createdb -U dryad_test_user dryad_test

# export PGPORT={{ dryad.testdb.port }}
export PGUSER=dryad_test_user
export PGDATABASE=dryad_test_db

export DRYAD_CODE_DIR=.
pwd
# from vagrant all
# dryad:
#  user: vagrant
#  user_home: /home/vagrant
#  repo_path: /home/vagrant/dryad-repo
#  tomcat_home: /home/vagrant/dryad-tomcat
#  dryad_home: vagrant-dryad
#  install_dir: /opt/dryad
#  admin_email: root@localhost
#  hostname: localhost
#  port: 9999
#  url: http://localhost:9999
#  doi:
#    username: dryad
#    password: 
#  db:
#    host: 127.0.0.1
#    port: 5432
#    name: dryad_repo
#    user: dryad_app
#    password: sidwell
#  testdb:
#    host: 127.0.0.1
#    port: 5432
#    name: dryad_test_db
#    user: dryad_test_user
#    password: sidwell
#
# from ansible dryad_setupdb.yml
#- name: Create Postgres user for dryad
#  postgresql_user: name={{ dryad.db.user }} role_attr_flags=CREATEDB password={{ dryad.db.password }}
#  sudo: yes
#  sudo_user: postgres
#
psql -U postgres -c "create user dryad_app with createdb;" 
#- name: Create Postgres database for dryad
#  postgresql_db: owner={{ dryad.db.user }} name={{ dryad.db.name }} login_user={{ dryad.db.user }} login_password={{ dryad.db.password }} login_host={{ dryad.db.host }} port={{ dryad.db.port }} encoding={{ postgresql.encoding }} lc_ctype='{{ postgresql.locale }}.{{ postgresql.encoding }}' lc_collate='{{ postgresql.locale }}.{{ postgresql.encoding }}'
createdb -U dryad_app dryad_repo
#- name: Create Postgres user for dryad test
#  postgresql_user: name={{ dryad.testdb.user }} role_attr_flags=CREATEDB password={{ dryad.testdb.password }}
#  sudo: yes
#  sudo_user: postgres
psql -U postgres -c "create user dryad_test_user with createdb;"
#- name: Create Postgres database for dryad test
#  postgresql_db: owner={{ dryad.testdb.user }} name={{ dryad.testdb.name }} login_user={{ dryad.testdb.user }} login_password={{ dryad.testdb.password }} login_host={{ dryad.testdb.host }} port={{ dryad.testdb.port }} encoding={{ postgresql.encoding }} lc_ctype='{{ postgresql.locale }}.{{ postgresql.encoding }}' lc_collate='{{ postgresql.locale }}.{{ postgresql.encoding }}'
createdb -U dryad_test_user dryad_test_db
#- psql -U postgres -c "create user dryad_test_user with createdb;"
#- createdb -U dryad_test_user dryad_test_db

psql -c '\l'
psql -c '\du'


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

