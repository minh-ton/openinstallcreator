#!/bin/sh

#  strcCheck.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/14/20.
#  Copyright © 2020 MinhTon. All rights reserved.

touch /tmp/CIMedia/InstallerIMGPath.CIM
INSTALLER_SHAREDSUPPORT_PATH=$(cat /tmp/CIMedia/InstallerPath.CIM)/Contents/SharedSupport
if [[ ! -e /tmp/InstallESD/BaseSystem.dmg ]]; then
    INSTALLER_IMAGES_PATH=$INSTALLER_SHAREDSUPPORT_PATH
fi
if [[ -e /tmp/InstallESD/BaseSystem.dmg ]]; then
    INSTALLER_IMAGES_PATH="/tmp/InstallESD"
fi
echo $INSTALLER_IMAGES_PATH >> /tmp/CIMedia/InstallerIMGPath.CIM
