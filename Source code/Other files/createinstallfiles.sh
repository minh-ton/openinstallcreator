#!/bin/sh

#  createinstallfiles.sh
#  openinstallcreator
#
#  Created by Ford on 4/18/20.
#  Copyright © 2020 MinhTon. All rights reserved.

installer_version_short=$(cat /tmp/installer_version_short)
installer_volume_path=$(cat /tmp/installer_volume_path)
installer_application_name=$(cat /tmp/installer_application_name)

if [[ $installer_version_short == "10.9." || $installer_version_short == "10.10" ]]; then
echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Kernel Cache</key>
<string>/.IABootFiles/kernelcache</string>
<key>Kernel Flags</key>
<string>container-dmg=file:///"$(echo $installer_application_name | sed 's/\ /%20/g')"/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg</string>
</dict>
</plist>" > "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
fi

if [[ $installer_version_short == "10.1"[1-2] ]]; then
echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Kernel Cache</key>
<string>/.IABootFiles/prelinkedkernel</string>
<key>Kernel Flags</key>
<string>container-dmg=file:///"$(echo $installer_application_name | sed 's/\ /%20/g')"/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg</string>
</dict>
</plist>" > "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
fi

if [[ $installer_version_short == "10.1"[3-5] ]]; then
echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Kernel Flags</key>
<string>root-dmg=file:///"$(echo $installer_application_name | sed 's/\ /%20/g')"/Contents/SharedSupport/BaseSystem.dmg</string>
</dict>
</plist>" > "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
fi


echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>AppName</key>
<string>"$installer_application_name"</string>
</dict>
</plist>" > "$installer_volume_path"/.IAPhysicalMedia
