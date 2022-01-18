#!/bin/bash

pushd $JQF_DIR
{
    # Instrument JQF examples
    java -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar examples/target/classes examples/target/classes-inst
    java -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar examples/target/test-classes examples/target/test-classes-inst
}
popd
