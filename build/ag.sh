#!/bin/bash

readonly TAG=portacle
readonly REPOSITORY=https://github.com/AkashaP/ag.git
readonly CONFIGURE_OPTIONS=("")

###

readonly PROGRAM=ag
source common.sh

function prepare() {
    cd "$SOURCE_DIR"
    ./autogen.sh
    ./configure --prefix="$INSTALL_DIR" "${CONFIGURE_OPTIONS[@]}" \
        || eexit "Configure failed. Maybe some dependencies are missing?"
}

function build() {
    cd "$SOURCE_DIR"
    local makeopts=""
    
    case "$PLATFORM" in
        win) makeopts="-f Makefile.w32" ;;
    esac
    
    make -j $MAXCPUS $makeopts \
        || eexit "The build failed. Please check the output for error messages."
}

function install() {
    cd "$SOURCE_DIR"
    make install \
        || eexit "The install failed. Please check the output for error messages."

    status 2 "Copying dependencies"
    ensure-dependencies $(find-binaries "$INSTALL_DIR/")

    case "$PLATFORM" in
        mac) mac-fixup-dependencies "$INSTALL_DIR/bin/ag"
             mac-fixup-lib-dependencies
             ;;
    esac
}

main
