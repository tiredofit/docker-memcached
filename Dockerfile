FROM docker.io/tiredofit/alpine:3.16
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

## Set Environment Variables
ENV MEMCACHED_VERSION=1.6.15 \
    IMAGE_NAME="tiredofit/memcached" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-memcached/"

RUN set -x && \
    addgroup -S -g 11211 memcached && \
    adduser -S -D -H -u 11211 -G memcached -g "Memcached" memcached && \
    apk add -t .memcached-build-deps \
                autoconf \
                automake \
                build-base \
                ca-certificates \
                coreutils \
                cyrus-sasl-dev \
                gcc \
                git \
                libc-dev \
                libevent-dev \
                linux-headers \
                make \
                musl-dev \
                openssl \
                openssl-dev \
                patch \
                perl \
                perl-io-socket-ssl \
                perl-utils \
                && \
    \
    git clone https://github.com/memcached/memcached /usr/src/memcached && \
    cd /usr/src/memcached && \
    git -C /usr/src/memcached checkout ${MEMCACHED_VERSION} && \
    sed -i "/#include <sys\/cdefs.h>/d" /usr/src/memcached/queue.h && \
    ./autogen.sh && \
    ./configure \
        --build="$(gnuArch)" \
        --enable-extstore \
        --enable-sasl \
        --enable-sasl-pwdb \
        --enable-tls \
        && \
    \
    make -j "$(nproc)" && \
    make install && \
    cd / && \
    runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \
    apk add -t .memcached-run-deps $runDeps && \
    apk del .memcached-build-deps && \
    rm -rf /var/cache/apk/*	&& \
    rm -rf /usr/src/* && \
    memcached -V

## Networking Setup
EXPOSE 11211

### Add Folders
ADD install/ /
