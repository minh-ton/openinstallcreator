#!/bin/sh

#  installerLIB.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/13/20.
#  Copyright © 2020 MinhTon. All rights reserved.

INSTALLER_PATH=$(cat /tmp/CIMedia/InstallerPath.CIM)
INSTALLER_PATH_NEW=$(echo $INSTALLER_PATH | sed 's/ /\\ /g' | rev | cut -c 2- | rev)
rm /tmp/CIMedia/InstallerPath.CIM
touch /tmp/CIMedia/InstallerPath.CIM
echo $INSTALLER_PATH_NEW >> /tmp/CIMedia/InstallerPath.CIM
