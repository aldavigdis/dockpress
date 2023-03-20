#!/bin/bash

apt-get update
apt-get remove php8.1-imagick -y
apt-get install build-essential libtiff-dev zlib1g-dev libfontconfig-dev \
                libfreetype-dev libgvc6 libheif-dev liblcms2-dev \
                libopenjp2-7-dev liblqr-1-0-dev libopenexr-dev \
                libpango1.0-dev libraw-dev libwmf-dev libxml2-dev \
                libzip-dev libzstd-dev libdjvulibre-dev libraqm-dev \
                libwebp-dev libltdl-dev php8.1-dev -y

curl -s -L "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs1000/ghostscript-10.0.0.tar.gz" | tar -C /tmp -zx
cd /tmp/ghost-* && ./configure CFLAGS=-O3 --prefix=/usr && make -j $(nproc) so && make soinstall
rm -rf /tmp/ghost-*
ldconfig

curl -s -L "https://imagemagick.org/archive/releases/ImageMagick-6.9.12-82.tar.gz" | tar -C /tmp -zx
cd /tmp/ImageMagick-* && ./configure CFLAGS=-O3 --with-modules --with-gslib=yes && make -j $(nproc) && make install
rm -rf /tmp/ImageMagick-*
ldconfig

curl -s -L "https://pecl.php.net/get/imagick-3.7.0.tgz" | tar -C /tmp -zx
cd /tmp/imagick-* && phpize && ./configure CFLAGS=-O3 --with-imagick=/opt/local && make -j $(nproc) && make install
rm -rf /tmp/imagick-*
ldconfig

echo "extension=imagick.so" > /etc/php/8.1/mods-available/imagick
phpenmod imagick
