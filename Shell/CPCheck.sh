#!/bin/sh

#  CPCheck.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/14/20.
#  Copyright © 2020 MinhTon. All rights reserved.

if [[ -z $(grep '[^[:space:]]' /tmp/CIMedia/InstallerPath.CIM) ]] ; then
echo "Empty"
fi
