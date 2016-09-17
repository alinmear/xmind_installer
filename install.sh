#!/bin/bash

_version="7.5-update1"
_wdir=`mktemp -d` && cd $dir

declare -r TRUE=0
declare -r FALSE=1

is_root_user() {
 [ $(id -u) -eq 0 ] && return $TRUE || return $FALSE
}

install() {
    echo "Starting Xmind Installation"

    echo "  * Downloading:"
    wget -U 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0' http://www.xmind.net/xmind/downloads/xmind-${_version}-linux_amd64.deb || exit 1

    echo "  * Extracting DEB:"
    ar -x xmind-${_version}-linux_amd64.deb  || echo "==> Warning: failed to extract"
    echo "  * Exctracting data.tar.gz:"
    tar xf data.tar.gz  || echo "==> Warning: failed to extract"

    echo "  * Moving xmind to /opt"
    [ -d /opt/xmind ] && rm -rf /opt/xmind && echo "/opt/xmind already existing. Removed it .."
    mv usr/lib/xmind /opt/ || echo "==> Warning: failed to move xmind to /opt"

    echo "  * Moving XMind.ini"
    mv etc/XMind.ini /opt/xmind/ ||  echo "==> Warning: failed to move XMind.ini to /opt/xmind"
    echo "  * Changing XMind lib path to /opt/xmind/XMind"
    sed -i -e 's|^XMIND=.*|XMIND=/opt/xmind/XMind|g' usr/bin/XMind || echo "==> Warning: failed to substitue"

    echo "  * Moving Xmind to /usr/bin/XMind"
    mv usr/bin/XMind /usr/bin/ || echo "==> Warning: failed to move"

    echo "  * Copying usr/share/* to /usr/share"
    cp -Rv usr/share/* /usr/share/ || echo "==> Warning: failed to copy"
}

cleanup() {
    echo "  * Leaving working dir"
    cd ..

    echo "  * Removing working dir"
    rm -Rv "${_wdir}" || echo "==> Warning: failed to remove working dir"
}

update_mime_desktop_db() {
    set -e
    echo "Updating desktop database"
    update-desktop-database
    echo "Updating mime database"
    update-mime-database /usr/share/mime/
    echo "Updating fonts cache"
    fc-cache --force
}

is_root_user || echo "No root privileges. Aborting ..." && exit 1
install
update_mime_desktop_db
cleanup

exit 0
