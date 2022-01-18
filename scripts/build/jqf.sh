#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

which mvn &> /dev/null || { echo "Please install maven" ; exit 1 ; }

# build JQF vanilla
git clone $JQF_VANILLA_REPO_URL $JQF_VANILLA_DIR
pushd $JQF_VANILLA_DIR
{
    git checkout $JQF_VANILLA_BRANCH
    # Fix bug in JQF vanilla driver
    sed 's/version="\(.*\)-SNAPSHOT"/version="\1"/g' -i scripts/jqf-driver.sh
    # Apply patch to dump generated input and stack-trace when found a failure
#    patch -p1 < $ROOT/patches/add-input-stacktrace.patch - no need now, this is in our fork.
    patch -p1 < $ROOT/patches/add-batik.patch
    mvn install
}
popd


# build JQF
git clone $JQF_REPO_URL $JQF_DIR
pushd $JQF_DIR
{
    git checkout $JQF_BRANCH
    mvn install

    # # build JQF closure test
    # pushd closure
    # {
    #     mvn test-compile
    #     sh getDeps.sh
    #     pushd deps
    #     {
    #         rm jqf*
    #     }
    #     popd
    # }
    # popd

}
popd
