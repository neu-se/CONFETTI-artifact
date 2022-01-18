#!/bin/bash

pushd $JQF_DIR
{
    # Instrument JQF examples
    java -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar examples/target/classes examples/target/classes-inst
    java -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar examples/target/test-classes examples/target/test-classes-inst

    # Instrument closure
    java -DspecialStrings=equals -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar $CLOSURE_DIR $CLOSURE_DIR-inst
    # Instrument ant
    java -DspecialStrings=equals -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar $ANT_DIR $ANT_DIR-inst
    # Instrument rhino
    java -DspecialStrings=equals -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar $RHINO_DIR $RHINO_DIR-inst
    # Instrument maven
    java -DspecialStrings=equals -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar $MAVEN_DIR $MAVEN_DIR-inst
    # Instrument BCEL
    java -DspecialStrings=equals -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar $BCEL_DIR $BCEL_DIR-inst
    # Instrument Batik
    java -DspecialStrings=equals -DaddCov -jar $KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar $BATIK_DIR $BATIK_DIR-inst
}
popd
