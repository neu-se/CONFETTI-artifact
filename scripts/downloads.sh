#!/bin/bash

JDK_FILE="jdk-8u241-linux-x64.tar.gz"
sudo apt update
sudo apt install -y ant maven unzip

mkdir $DOWNLOAD_DIR
pushd $DOWNLOAD_DIR
{
    while :
    do
        if [[ $(find $JDK_FILE -type f -size +100M 2>/dev/null) ]]; then
            break
        fi
        rm $JDK_FILE
        if [ -n "$AWS_S3_BUCKET" ]; then
            aws s3 cp s3://$AWS_S3_BUCKET/$JDK_FILE .
        else
            $WGET --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=14gX1BiEDDPArA0iOmxB0yWZmQxPAVjaS' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=14gX1BiEDDPArA0iOmxB0yWZmQxPAVjaS" -O $JDK_FILE && rm -rf /tmp/cookies.txt
        fi
    done
    $WGET https://github.com/Z3Prover/z3/releases/download/z3-4.6.0/z3-4.6.0-x64-ubuntu-16.04.zip
}
