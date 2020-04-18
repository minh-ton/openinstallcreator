#!/bin/bash

Input_Off()
{
	stty -echo
}

Input_On()
{
	stty echo
}

Output_Off()
{
	if [[ $verbose == "1" ]]; then
		"$@"
	else
		"$@" &>/dev/null
	fi
}

Check_Environment()
{
	echo -e ${text_progress}"> Checking system environment."${erase_style}

	if [ -d /Install\ *.app ]; then
		environment="installer"
	fi

	if [ ! -d /Install\ *.app ]; then
		environment="system"
	fi

	echo -e ${move_up}${erase_line}${text_success}"+ Checked system environment."${erase_style}
}

Check_Root()
{
	echo -e ${text_progress}"> Checking for root permissions."${erase_style}

	if [[ $environment == "installer" ]]; then
		root_check="passed"
		echo -e ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
	else

		if [[ $(whoami) == "root" && $environment == "system" ]]; then
			root_check="passed"
			echo -e ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
		fi

		if [[ ! $(whoami) == "root" && $environment == "system" ]]; then
			root_check="failed"
			echo -e ${text_error}"- Root permissions check failed."${erase_style}
			echo -e ${text_message}"/ Run this tool with root permissions."${erase_style}

			Input_On
			exit
		fi

	fi
}

Input_Installer()
{
	echo -e ${text_message}"/ What installer would you like to use?"${erase_style}
	echo -e ${text_message}"/ Input an installer path."${erase_style}

	if [[ "$installer_application_path" ]]; then
		echo -e "/ $installer_application_path"${erase_style}
	else
		Input_On
		read -e -p "/ " installer_application_path
		Input_Off
	fi

	installer_application_name="${installer_application_path##*/}"
	installer_application_name_partial="${installer_application_name%.app}"

	installer_sharedsupport_path="$installer_application_path/Contents/SharedSupport"
}

Check_Installer_Stucture()
{
	Output_Off hdiutil attach "$installer_sharedsupport_path"/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse

	echo -e ${text_progress}"> Checking installer structure."${erase_style}

		if [[ -e /tmp/InstallESD/BaseSystem.dmg ]]; then
			installer_images_path="/tmp/InstallESD"
		fi
		if [[ -e "$installer_sharedsupport_path"/BaseSystem.dmg ]]; then
			installer_images_path="$installer_sharedsupport_path"
		fi

	echo -e ${move_up}${erase_line}${text_success}"+ Checked installer structure."${erase_style}


	echo -e ${text_progress}"> Mounting installer disk images."${erase_style}

		Output_Off hdiutil attach "$installer_images_path"/BaseSystem.dmg -mountpoint /tmp/Base\ System -nobrowse

	echo -e ${move_up}${erase_line}${text_success}"+ Mounted installer disk images."${erase_style}
}

Check_Installer_Version()
{
	echo -e ${text_progress}"> Checking installer version."${erase_style}

		installer_version="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		installer_version_short="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"

	echo -e ${move_up}${erase_line}${text_success}"+ Checked installer version."${erase_style}	
}

Input_Volume()
{
	echo -e ${text_message}"/ What volume would you like to use?"${erase_style}
	echo -e ${text_message}"/ Input a volume name."${erase_style}

	for volume_path in /Volumes/*; do
		volume_name="${volume_path#/Volumes/}"
	
		if [[ ! "$volume_name" == com.apple* ]]; then
			echo -e ${text_message}"/     ${volume_name}"${erase_style} | sort -V
		fi

	done

	if [[ "$installer_volume_name" ]]; then
		echo -e "/ $installer_volume_name"${erase_style}
	else
		Input_On
		read -e -p "/ " installer_volume_name
		Input_Off
	fi

	installer_volume_path="/Volumes/$installer_volume_name"
}

Create_Installer_Media()
{
	echo -e ${text_progress}"> Erasing installer volume."${erase_style}

		Output_Off diskutil eraseVolume HFS+ "$installer_application_name_partial" "$installer_volume_path"

		installer_volume_name="$installer_application_name_partial"
		installer_volume_path="/Volumes/$installer_volume_name"

	echo -e ${move_up}${erase_line}${text_success}"+ Erased installer volume."${erase_style}


	echo -e ${text_progress}"> Creating installer folders."${erase_style}

		mkdir -p "$installer_volume_path"/Library/Preferences/SystemConfiguration
		mkdir -p "$installer_volume_path"/System/Library/CoreServices

		mkdir -p "$installer_volume_path"/usr/standalone/i386

		if [[ $installer_version_short == "10.9." || $installer_version_short == "10.1"[0-2] ]]; then
			mkdir "$installer_volume_path"/.IABootFiles
			chflags hidden "$installer_volume_path"/.IABootFiles
		fi

		if [[ $installer_version_short == "10.9." || $installer_version_short == "10.10" ]]; then
			mkdir -p "$installer_volume_path"/System/Library/Caches/com.apple.kext.caches/Startup
		fi

		if [[ $installer_version_short == "10.1"[2-5] ]]; then
			mkdir -p "$installer_volume_path"/System/Library/PrelinkedKernels
		fi

		chflags hidden "$installer_volume_path"/Library
		chflags hidden "$installer_volume_path"/System
		chflags hidden "$installer_volume_path"/usr


	echo -e ${move_up}${erase_line}${text_success}"+ Created installer folders."${erase_style}
		

	echo -e ${text_progress}"> Copying installer files."${erase_style}

		cp -R "$installer_application_path" "$installer_volume_path"/

		if [[ $installer_version_short == "10.9." || $installer_version_short == "10.1"[0-2] ]]; then
			cp /tmp/Base\ System/System/Library/CoreServices/boot.efi "$installer_volume_path"/.IABootFiles
			cp /tmp/Base\ System/System/Library/CoreServices/PlatformSupport.plist "$installer_volume_path"/.IABootFiles

			cp /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist "$installer_volume_path"/.IABootFilesSystemVersion.plist
			chflags hidden "$installer_volume_path"/.IABootFilesSystemVersion.plist
			
			cp /tmp/Base\ System/System/Library/CoreServices/boot.efi "$installer_volume_path"/usr/standalone/i386
		fi

		if [[ $installer_version_short == "10.9." || $installer_version_short == "10.10" ]]; then
			cp /tmp/Base\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache "$installer_volume_path"/System/Library/Caches/com.apple.kext.caches/Startup
			cp /tmp/Base\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache "$installer_volume_path"/.IABootFiles
		fi

		if [[ $installer_version_short == "10.1"[1-2] ]]; then
			cp /tmp/Base\ System/System/Library/PrelinkedKernels/prelinkedkernel "$installer_volume_path"/.IABootFiles
			cp /tmp/Base\ System/System/Library/PrelinkedKernels/prelinkedkernel "$installer_volume_path"/System/Library/PrelinkedKernels
		fi

		if [[ $installer_version_short == "10.1"[3-5] ]]; then
			cp /tmp/Base\ System/System/Library/CoreServices/boot.efi* "$installer_volume_path"/System/Library/CoreServices
			cp /tmp/Base\ System/System/Library/CoreServices/bootbase.efi* "$installer_volume_path"/System/Library/CoreServices
			cp /tmp/Base\ System/System/Library/CoreServices/BridgeVersion.bin "$installer_volume_path"/System/Library/CoreServices

			cp /tmp/Base\ System/System/Library/PrelinkedKernels/prelinkedkernel "$installer_volume_path"/System/Library/PrelinkedKernels
			cp /tmp/Base\ System/System/Library/PrelinkedKernels/immutablekernel* "$installer_volume_path"/System/Library/PrelinkedKernels

			cp -R /tmp/Base\ System/usr/standalone/i386/SecureBoot.bundle "$installer_volume_path"/usr/standalone/i386
		fi

		cp /tmp/Base\ System/System/Library/CoreServices/boot.efi "$installer_volume_path"/System/Library/CoreServices
		cp /tmp/Base\ System/System/Library/CoreServices/PlatformSupport.plist "$installer_volume_path"/System/Library/CoreServices
		cp /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist "$installer_volume_path"/System/Library/CoreServices

	echo -e ${move_up}${erase_line}${text_success}"+ Copied installer files."${erase_style}


	echo -e ${text_progress}"> Creating installer files."${erase_style}

		if [[ $installer_version_short == "10.9." || $installer_version_short == "10.10" ]]; then
			echo -e "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Kernel Cache</key>
	<string>/.IABootFiles/kernelcache</string>
	<key>Kernel Flags</key>
	<string>container-dmg=file:///"$(echo -e $installer_application_name | sed 's/\ /%20/g')"/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg</string>
</dict>
</plist>" > "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
		fi

		if [[ $installer_version_short == "10.1"[1-2] ]]; then
			echo -e "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Kernel Cache</key>
	<string>/.IABootFiles/prelinkedkernel</string>
	<key>Kernel Flags</key>
	<string>container-dmg=file:///"$(echo -e $installer_application_name | sed 's/\ /%20/g')"/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg</string>
</dict>
</plist>" > "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
		fi

		if [[ $installer_version_short == "10.1"[3-5] ]]; then
			echo -e "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Kernel Flags</key>
	<string>root-dmg=file:///"$(echo -e $installer_application_name | sed 's/\ /%20/g')"/Contents/SharedSupport/BaseSystem.dmg</string>
</dict>
</plist>" > "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
		fi

		if [[ $installer_version_short == "10.9." || $installer_version_short == "10.1"[0-2] ]]; then
			cp "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist "$installer_volume_path"/.IABootFiles
		fi
	
		echo -e "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AppName</key>
	<string>"$installer_application_name"</string>
</dict>
</plist>" > "$installer_volume_path"/.IAPhysicalMedia


		touch "$installer_volume_path"/.metadata_never_index

	echo -e ${move_up}${erase_line}${text_success}"+ Created installer files."${erase_style}


	echo -e ${text_progress}"> Unmounting installer disk images."${erase_style}

		Output_Off hdiutil detach /tmp/Base\ System
		Output_Off hdiutil detach /tmp/InstallESD

	echo -e ${move_up}${erase_line}${text_success}"+ Unmounted installer disk images."${erase_style}


	if [[ $installer_version_short == "10.9." || $installer_version_short == "10.1"[0-2] ]]; then
		bless --folder "$installer_volume_path"/.IABootFiles --label "$installer_volume_name"
	fi

	if [[ $installer_version_short == "10.1"[3-5] ]]; then
		bless --folder "$installer_volume_path"/System/Library/CoreServices --label "$installer_volume_name"
	fi
}


End()
{
	echo -e ${text_message}"/ Thank you for using openinstallmedia."${erase_style}

	Input_On
	exit
}


Input_Off
Escape_Variables
Parameter_Variables
Check_Environment
Check_Root
Input_Installer
Check_Installer_Stucture
Check_Installer_Version
Input_Volume
Create_Installer_Media
End
