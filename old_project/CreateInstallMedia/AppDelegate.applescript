--
--  AppDelegate.applescript
--  CreateInstallMedia
--
--  Created by Ford on 3/11/20.
--  Copyright © 2020 MinhTon. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
    property SelectVolumePopUp : missing value
    property SelectInstallerButton : missing value
    property CreatePatchedInstallerTick : missing value
    property progressLabel : missing value
    property progressContinueButton : missing value
    property progressBar : missing value
    property statusText : missing value
    property VolumeSelected : missing value
    property InstallerSelected : missing value
    property refreshButton : missing value
    property VolumeNotSelected : missing value
    property InstallerNotSelected : missing value
    
    on downloadInstallerMenuClicked_(sender)
        -- I will implement this later
    end downloadInstallerMenuClicked_
    
    on refreshClicked_(sender)
        SelectVolumePopUp's addItemsWithTitles_{" "}
        set VolumesList to (get paragraphs of(do shell script "ls /Volumes"))
        SelectVolumePopUp's addItemsWithTitles_(VolumesList)
    end refreshClicked_
    
    on browseInstaller_(sender)
        set macOSInstaller to choose file with prompt "Please select a macOS Installer to process:"
        set macOSInstaller to POSIX path of macOSInstaller
        do shell script "rm /tmp/CIMedia/InstallerPath.CIM"
        do shell script "echo " & macOSInstaller & " >> /tmp/CIMedia/InstallerPath.CIM"
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set InstallerlibSH to quoted form of (app_directory & "installerLIB.sh") as string
        do shell script "chmod +x " & InstallerlibSH
        do shell script InstallerlibSH
        
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set CPCsh to quoted form of (app_directory & "CPCheck.sh") as string
        set CPCsh2 to quoted form of (app_directory & "CPCheck.sh") as string
        set CP1 to (do shell script CPCsh)
        set CP2 to (do shell script CPCsh2)
        if CP1 = "Empty" and CP2 = "Empty" then
            progressContinueButton's setEnabled_(false)
        else
            progressContinueButton's setEnabled_(true)
        end if
        InstallerSelected's setHidden_(false)
        InstallerNotSelected's setHidden_(true)
    end browseInstaller_
    
    on selectVolumePopUpClicked_(sender)
        set TargetVolume to "/Volumes/" & (SelectVolumePopUp's titleOfSelectedItem() as text)
        do shell script "rm /tmp/CIMedia/TargetVolume.CIM"
        do shell script "echo " & TargetVolume & " >> /tmp/CIMedia/TargetVolume.CIM"
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set VolumelibSH to quoted form of (app_directory & "volumeLIB.sh") as string
        do shell script "chmod +x " & VolumelibSH
        do shell script VolumelibSH
        
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set CPCsh to quoted form of (app_directory & "CPCheck.sh") as string
        set CPCsh2 to quoted form of (app_directory & "CPCheck.sh") as string
        set CP1 to (do shell script CPCsh)
        set CP2 to (do shell script CPCsh2)
        if CP1 = "Empty" and CP2 = "Empty" then
            progressContinueButton's setEnabled_(false)
        else
            progressContinueButton's setEnabled_(true)
        end if
        VolumeSelected's setHidden_(false)
        VolumeNotSelected's setHidden_(true)
    end selectVolumePopUpClicked_
    
    on ContinueClicked_(sender)
        set CreatePatchedInstaller to (do shell script "cat /tmp/CIMedia/CIMFlags.CIM")
        if CreatePatchedInstaller = "no" then
            progressContinueButton's setEnabled_(false)
            SelectVolumePopUp's setEnabled_(false)
            SelectInstallerButton's setEnabled_(false)
            refreshButton's setEnabled_(false)
            progressLabel's setStringValue:"Preparing files..."
            do shell script "echo" with administrator privileges
            Create_Normal_Install_Media()
        end if
    end ContinueClicked_
    
    on Create_Normal_Install_Media()
        progressLabel's setStringValue:"Mounting InstallESD.dmg..."
        tell progressBar to setDoubleValue:5
        set TargetVolume to (do shell script "cat /tmp/CIMedia/TargetVolume.CIM")
        set InstallerPath to (do shell script "cat /tmp/CIMedia/InstallerPath.CIM")
        delay 5
        do shell script "hdiutil attach " & InstallerPath & "/Contents/SharedSupport/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse" with administrator privileges
        
        -- Checking structure
        delay 5
        progressLabel's setStringValue:"Checking installer structure..."
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set strcCheckSH to quoted form of (app_directory & "strcCheck.sh")
        do shell script "chmod +x " & strcCheckSH with administrator privileges
        do shell script strcCheckSH with administrator privileges
        set InstallerIMGPath to (do shell script "cat /tmp/CIMedia/InstallerIMGPath.CIM")
        progressLabel's setStringValue:"Mounting BaseSystem.dmg..."
        tell progressBar to setDoubleValue:10
        -- Checked Installer Structure!
        
        -- Mounting BaseSystem.dmg
        delay 5
        do shell script "hdiutil attach " & InstallerIMGPath & "/BaseSystem.dmg -mountpoint /tmp/BaseSystem -nobrowse" with administrator privileges
        -- Mounted BaseSystem.dmg
        
        -- Erasing installer volume
        delay 5
        progressLabel's setStringValue:"Erasing installer volume..."
        set volname to quoted form of (app_directory & "Volname.sh")
        do shell script "chmod +x " & volname with administrator privileges
        set NewVolumeName to (do shell script volname)
        do shell script "diskutil eraseVolume HFS+ " & NewVolumeName & " " & TargetVolume with administrator privileges
        do shell script "rm /tmp/CIMedia/TargetVolume.CIM" with administrator privileges
        do shell script "echo " & NewVolumeName & " >> /tmp/CIMedia/TargetVolume.CIM" with administrator privileges
        set VolumelibSH to quoted form of (app_directory & "volumeLIB.sh") as string
        do shell script "chmod +x " & VolumelibSH with administrator privileges
        do shell script VolumelibSH with administrator privileges
        set NewVolumePathOriginal to (do shell script "cat /tmp/CIMedia/TargetVolume.CIM")
        set NewVolumePath to "/Volumes/" & NewVolumePathOriginal
        tell progressBar to setDoubleValue:15
        -- Erased installer volume
        
        -- Checking installer version
        delay 5
        progressLabel's setStringValue:"Checking installer version..."
        set installerVersion to (do shell script "defaults read /tmp/BaseSystem/System/Library/CoreServices/SystemVersion.plist ProductVersion")
        set installerVersionShort to (do shell script "defaults read /tmp/BaseSystem/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
        -- Checked installer version
        
        -- Creating installer folders
        delay 2
        progressLabel's setStringValue:"Creating SystemConfiguration..."
        do shell script "mkdir -p " & NewVolumePath & "/Library/Preferences/SystemConfiguration" with administrator privileges
        delay 1
        progressLabel's setStringValue:"Creating CoreServices..."
        do shell script "mkdir -p " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
        delay 1
        progressLabel's setStringValue:"Creating system folders..."
        do shell script "mkdir -p " & NewVolumePath & "/usr/standalone/i386" with administrator privileges
        
        if installerVersionShort = "10.10" or installerVersionShort = "10.11" or installerVersionShort = "10.12" then
            delay 1
            progressLabel's setStringValue:"Creating .IABootFiles..."
            do shell script "mkdir " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "chflags hidden " & NewVolumePath & "/.IABootFiles" with administrator privileges
        end if
        
        if installerVersionShort = "10.10" then
            delay 1
            progressLabel's setStringValue:"Creating Cache folder..."
            do shell script "mkdir -p " & NewVolumePath & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
        end if
        
        if installerVersionShort = "10.12" or installerVersionShort = "10.13" or installerVersionShort = "10.14" or installerVersionShort = "10.15" then
            delay 1
            progressLabel's setStringValue:"Creating PrelinkedKernels..."
            do shell script "mkdir -p " & NewVolumePath & "/System/Library/PrelinkedKernels" with administrator privileges
        end if
        
        do shell script "chflags hidden " & NewVolumePath & "/Library" with administrator privileges
        do shell script "chflags hidden " & NewVolumePath & "/System" with administrator privileges
        do shell script "chflags hidden " & NewVolumePath & "/usr" with administrator privileges
        
        if installerVersionShort = "10.10" then
            set OSname to "Install OS X Yosemite.app"
            else if installerVersionShort = "10.11" then
            set OSname to "Install OS X El Capitan.app"
            else if installerVersionShort = "10.12" then
            set OSname to "Install macOS Sierra.app"
            else if installerVersionShort = "10.13" then
            set OSname to "Install macOS High Sierra.app"
            else if installerVersionShort = "10.14" then
            set OSname to "Install macOS Mojave.app"
            else if installerVersionShort = "10.15" then
            set OSname to "Install macOS Catalina.app"
        end if
        progressLabel's setStringValue:"Copying " & OSname
        tell progressBar to setDoubleValue:20
        -- Created installer folders
        
        -- Copy installer files
        delay 5
        set YosemiteSH to quoted form of (app_directory & "Yosemite.sh")
        set ElCapitanSH to quoted form of (app_directory & "ElCapitan.sh")
        set SierraSH to quoted form of (app_directory & "Sierra.sh")
        set HighSierraSH to quoted form of (app_directory & "HighSierra.sh")
        set MojaveSH to quoted form of (app_directory & "Mojave.sh")
        set CatalinaSH to quoted form of (app_directory & "Catalina.sh")
        
        do shell script "chmod +x " & YosemiteSH with administrator privileges
        do shell script "chmod +x " & ElCapitanSH with administrator privileges
        do shell script "chmod +x " & SierraSH with administrator privileges
        do shell script "chmod +x " & HighSierraSH with administrator privileges
        do shell script "chmod +x " & MojaveSH with administrator privileges
        do shell script "chmod +x " & CatalinaSH with administrator privileges
        
        if installerVersionShort = "10.10" then
            set OSname to (do shell script YosemiteSH)
        else if installerVersionShort = "10.11" then
            set OSname to (do shell script ElCapitanSH)
        else if installerVersionShort = "10.12" then
            set OSname to (do shell script SierraSH)
        else if installerVersionShort = "10.13" then
            set OSname to (do shell script HighSierraSH)
        else if installerVersionShort = "10.14" then
            set OSname to (do shell script MojaveSH)
        else if installerVersionShort = "10.15" then
            set OSname to (do shell script CatalinaSH)
        end if
        tell progressBar to setDoubleValue:25
        
        do shell script "cp -R " & InstallerPath & " " & NewVolumePath & OSname with administrator privileges
        tell progressBar to setDoubleValue:50
        
        delay 5
        progressLabel's setStringValue:"Copying System Boot files..."
        if installerVersionShort = "10.10" or installerVersionShort = "10.11" or installerVersionShort = "10.12" then
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/boot.efi " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/PlatformSupport.plist " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/SystemVersion.plist " & NewVolumePath & "/.IABootFilesSystemVersion.plist" with administrator privileges
            do shell script "chflags hidden " & NewVolumePath & "/.IABootFilesSystemVersion.plist" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/boot.efi " & NewVolumePath & "/usr/standalone/i386" with administrator privileges
            delay 1
            tell progressBar to setDoubleValue:60
        end if
        
        if installerVersionShort = "10.10" then
            do shell script "cp /tmp/BaseSystem/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache " & NewVolumePath & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache " & NewVolumePath & "/.IABootFiles" with administrator privileges
            delay 1
            tell progressBar to setDoubleValue:70
        end if
        
        if installerVersionShort = "10.11" or installerVersionShort = "10.12" then
            do shell script "cp /tmp/BaseSystem/System/Library/PrelinkedKernels/prelinkedkernel " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/PrelinkedKernels/prelinkedkernel " & NewVolumePath & "/System/Library/PrelinkedKernels" with administrator privileges
            delay 1
            tell progressBar to setDoubleValue:85
        end if
        
        if installerVersionShort = "10.13" or installerVersionShort = "10.14" or installerVersionShort = "10.15" then
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/boot.efi* " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/bootbase.efi* " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/BridgeVersion.bin " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/PrelinkedKernels/prelinkedkernel " & NewVolumePath & "/System/Library/PrelinkedKernels" with administrator privileges
            do shell script "cp /tmp/BaseSystem/System/Library/PrelinkedKernels/immutablekernel* " & NewVolumePath & "/System/Library/PrelinkedKernels" with administrator privileges
            do shell script "cp -R /tmp/BaseSystem/usr/standalone/i386/SecureBoot.bundle " & NewVolumePath & "/usr/standalone/i386" with administrator privileges
            delay 1
            tell progressBar to setDoubleValue:87
        end if
        
        do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/boot.efi " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
        do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/PlatformSupport.plist " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
        do shell script "cp /tmp/BaseSystem/System/Library/CoreServices/SystemVersion.plist " & NewVolumePath & "/System/Library/CoreServices" with administrator privileges
        delay 1
        tell progressBar to setDoubleValue:90
        
        -- Copied installer files... What a great process...
        
        -- Creating installer files (com.apple.Boot.plist)
        delay 5
        progressLabel's setStringValue:"Creating installer boot files..."
        if installerVersionShort = "10.10" then
            set YosemiteBootPlist to quoted form of (app_directory & "Yosemite.com.apple.Boot.plist")
            set YosemiteFiles to quoted form of (app_directory & "YosemiteIAPhysicalMedia")
            do shell script "cp " & YosemiteBootPlist & " " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" with administrator privileges
            do shell script "cp " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "cp " & YosemiteFiles & " " & NewVolumePath & "/.IAPhysicalMedia" with administrator privileges
        end if
        
        if installerVersionShort = "10.11" then
            set ElCapitanBootPlist to quoted form of (app_directory & "ElCapitan.com.apple.Boot.plist")
            set ElCapitanFiles to quoted form of (app_directory & "ElCapitanIAPhysicalMedia")
            do shell script "cp " & ElCapitanBootPlist & " " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" with administrator privileges
            do shell script "cp " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "cp " & ElCapitanFiles & " " & NewVolumePath & "/.IAPhysicalMedia" with administrator privileges
        end if
        
        if installerVersionShort = "10.12" then
            set SierraBootPlist to quoted form of (app_directory & "Sierra.com.apple.Boot.plist")
            set SierraFiles to quoted form of (app_directory & "SierraIAPhysicalMedia")
            do shell script "cp " & SierraBootPlist & " " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" with administrator privileges
            do shell script "cp " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist " & NewVolumePath & "/.IABootFiles" with administrator privileges
            do shell script "cp " & SierraFiles & " " & NewVolumePath & "/.IAPhysicalMedia" with administrator privileges
        end if
        
        if installerVersionShort = "10.13" then
            set HighSierraBootPlist to quoted form of (app_directory & "HighSierra.com.apple.Boot.plist")
            set HighSierraFiles to quoted form of (app_directory & "HighSierraIAPhysicalMedia")
            do shell script "cp " & HighSierraBootPlist & " " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" with administrator privileges
            do shell script "cp " & HighSierraFiles & " " & NewVolumePath & "/.IAPhysicalMedia" with administrator privileges
        end if
        
        if installerVersionShort = "10.14" then
            set MojaveBootPlist to quoted form of (app_directory & "Mojave.com.apple.Boot.plist")
            set MojaveFiles to quoted form of (app_directory & "MojaveIAPhysicalMedia")
            do shell script "cp " & MojaveBootPlist & " " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" with administrator privileges
            do shell script "cp " & MojaveFiles & " " & NewVolumePath & "/.IAPhysicalMedia" with administrator privileges
        end if
        
        if installerVersionShort = "10.15" then
            set CatalinaBootPlist to quoted form of (app_directory & "Catalina.com.apple.Boot.plist")
            set CatalinaFiles to quoted form of (app_directory & "CatalinaIAPhysicalMedia")
            do shell script "cp " & CatalinaBootPlist & " " & NewVolumePath & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" with administrator privileges
            do shell script "cp " & CatalinaFiles & " " & NewVolumePath & "/.IAPhysicalMedia" with administrator privileges
        end if
        
        do shell script "touch " & NewVolumePath & "/.metadata_never_index"
        delay 1
        tell progressBar to setDoubleValue:95
        -- Created installer files
        
        -- Unmounting disk images
        delay 5
        progressLabel's setStringValue:"Unmounting BaseSystem.dmg..."
        do shell script "hdiutil detach /tmp/BaseSystem" with administrator privileges
        delay 5
        progressLabel's setStringValue:"Unmounting InstallESD.dmg..."
        do shell script "hdiutil detach /tmp/InstallESD" with administrator privileges
        delay 1
        tell progressBar to setDoubleValue:98
        -- Unmounted disk images
        
        -- Making disk bootable...
        delay 5
        progressLabel's setStringValue:"Making disk bootable..."
        if installerVersionShort = "10.10" or installerVersionShort = "10.11" or installerVersionShort = "10.12" then
            do shell script "bless --folder " & NewVolumePath & "/.IABootFiles --label " & NewVolumeName with administrator privileges
        end if
        
        if installerVersionShort = "10.13" or installerVersionShort = "10.14" or installerVersionShort = "10.15" then
            do shell script "bless --folder " & NewVolumePath & "/System/Library/CoreServices --label " & NewVolumeName with administrator privileges
        end if
        delay 1
        tell progressBar to setDoubleValue:100
    
        -- Disk is bootable!
        delay 5
        progressLabel's setStringValue:"Your bootable installer is created successfully."
        -- Thank you for using CreateInstallMedia
        
    end Create_Normal_Install_Media
    
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        set VolumesList to c(get paragraphs of(do shell script "ls /Volumes"))
        SelectVolumePopUp's addItemsWithTitles_(VolumesList)
        set username to (do shell script "whoami")
        statusText's setStringValue:"Welcome to macOS Installer Creator!" & return & return & "Please make sure that the targeted drive is backed up before being erased to make a bootable macOS Installer."
        progressLabel's setStringValue:"Ready!"
        do shell script "mkdir /tmp/CIMedia"
        do shell script "touch /tmp/CIMedia/InstallerPath.CIM"
        do shell script "touch /tmp/CIMedia/TargetVolume.CIM"
        do shell script "touch /tmp/CIMedia/CIMFlags.CIM"
        do shell script "echo " & "no" & " >> /tmp/CIMedia/CIMFlags.CIM"
        progressContinueButton's setEnabled_(false)
        CreatePatchedInstallerTick's setEnabled_(false)     -- Add in future updates
        
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set CPCsh to quoted form of (app_directory & "CPCheck.sh") as string
        set CPCsh2 to quoted form of (app_directory & "CPCheck.sh") as string
        do shell script "chmod +x " & CPCsh
        do shell script "chmod +x " & CPCsh2
        
        VolumeSelected's setHidden_(true)
        InstallerSelected's setHidden_(true)
	end applicationWillFinishLaunching_
    
	on applicationShouldTerminate_(sender)
        do shell script "rm -R /tmp/CIMedia"
		-- Insert code here to do any housekeeping before your application quits
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
	
end script
