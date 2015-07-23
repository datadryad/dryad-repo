#!/bin/sh

set -ex
wget http://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz -O /tmp/apache-maven-2.2.1-bin.tar.gz
tar xzf /tmp/apache-maven-2.2.1-bin.tar.gz

# Travis build machines have an /etc/mavenrc file that sets M2_HOME to the maven3 version
# Need to override this variable in ~/.mavenrc to use our maven2.

echo "export M2_HOME=$TRAVIS_BUILD_DIR/apache-maven-2.2.1" > "$HOME/.mavenrc"
ls -l $HOME/
cp $TRAVIS_BUILD_DIR/dspace/etc/server/settings.xml $HOME/.m2/

cat $HOME/.m2/settings.xml