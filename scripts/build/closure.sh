#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

which mvn &> /dev/null || { echo "Please install maven" ; exit 1 ; }

## # build closure
## git clone $CLOSURE_REPO_URL $CLOSURE_DIR
## pushd $CLOSURE_DIR
## {
##     git checkout $CLOSURE_BRANCH
##     mvn install -DskipTests -pl externs/pom.xml,pom-main.xml,pom-main-shaded.xml
## }
## popd

# build Closure HEAD from source
## git clone $CLOSURE_REPO_URL $CLOSURE_DIR-HEAD
## pushd $CLOSURE_DIR-HEAD
## {
##     mvn package -DskipTests -pl externs/pom.xml,pom-main.xml,pom-main-shaded.xml
## }
## popd

# get Closure from Maven
pushd $CLOSURE_DIR
{
    # Get all dependencies from Maven
    ./getDeps.sh
}
popd

# get Closure HEAD from Maven
pushd $CLOSURE_DIR-HEAD
{
    # Get all dependencies from Maven
    ./getDeps.sh
}
popd
