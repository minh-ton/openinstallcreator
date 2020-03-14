#!/bin/sh

#  volumeLIB.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/13/20.
#  Copyright © 2020 MinhTon. All rights reserved.

VOLUME_PATH=$(cat /tmp/CIMedia/TargetVolume.CIM)
VOLUME_PATH_NEW=$(echo $VOLUME_PATH | sed 's/ /\\ /g')
rm /tmp/CIMedia/TargetVolume.CIM
touch /tmp/CIMedia/TargetVolume.CIM
echo $VOLUME_PATH_NEW >> /tmp/CIMedia/TargetVolume.CIM
