#!/bin/sh

#  Volname.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/15/20.
#  Copyright © 2020 MinhTon. All rights reserved.

installer_application_path=$(cat /tmp/CIMedia/InstallerPath.CIM)
installer_application_name="${installer_application_path##*/}"
installer_application_name_partial="${installer_application_name%.app}"
installer_volume_name="$installer_application_name_partial"
echo $installer_volume_name
