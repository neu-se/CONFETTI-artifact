#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

which ant &> /dev/null || { echo "Please install ant" ; exit 1 ; }
which mvn &> /dev/null || { echo "Please install maven" ; exit 1 ; }

# build green
git clone $GREEN_REPO_URL $INSTALL_DIR/green
pushd $INSTALL_DIR/green/green
{
    ant clean
    ant install
}
popd

# build knarr
git clone $KNARR_REPO_URL $KNARR_DIR
pushd $KNARR_DIR/knarr
{
    mvn package -DskipTests
    rm -rf target/jre-inst
    ./instrumentJRE.sh "-DspecialStrings=length,startsWith,equals" "-Xmx1G"
    mvn install -DskipTests
}
popd

pushd $KNARR_DIR/knarr-server
{
    mvn install -DskipTests
}
popd
