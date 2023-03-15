#!/bin/bash

sudo apt-get update
sudo apt-get install build-essential libtiff-dev -y

curl -s -L "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs1000/ghostpdl-10.0.0.tar.gz" | tar -C /tmp -zx

cd /tmp/ghostpdl-10.0.0 && ./configure --prefix=/usr && make && make install
