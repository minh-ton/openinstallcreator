#!/bin/sh

#  InstallerValidation.sh
#  CreateInstallMedia
#
#  Created by Ford on 3/13/20.
#  Copyright © 2020 MinhTon. All rights reserved.

FILE=$1
if [ -f $FILE ]; then
    echo "valid"
else
    echo "invalid"
fi
