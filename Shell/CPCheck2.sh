#!/bin/sh

#  CPCheck2.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/14/20.
#  Copyright © 2020 MinhTon. All rights reserved.

if [[ -z $(grep '[^[:space:]]' /tmp/CIMedia/TargetVolume.CIM) ]] ; then
echo "Empty"
fi
