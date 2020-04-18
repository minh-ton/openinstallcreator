--
--  AppDelegate.applescript
--  openinstallcreator
--
--  Created by Ford on 4/2/20.
--  Copyright © 2020 MinhTon. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
    
    -- View 1
    property selectVolumePopUp0 : missing value
    property selectInstallerButton0 : missing value
    property progressBar0 : missing value
    property progressText0 : missing value
    property continueButton0 : missing value
    property continueText0 : missing value
    
    
   -----------------------------------------------------------------------------------
                        --  FIRST VIEW  -  NORMAL BOOTABLE INSTALLER --
   
    on SelectVolumePopUp0Clicked_(sender)
        set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
        set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
        set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/openinstallercreatorflags.plist"
        -- set VolumeSizeCheck to (do shell script "defaults read " & flagspath & " CheckDiskSize")
        -- set VolumeSize to (do shell script "df -H /Volumes/" & (selectVolumePopUp0's titleOfSelectedItem() as text) & " | awk '{printf(" & (quoted form of "%s\n") & ", $2)}' | awk NR\\>1 | rev | cut -c 2- | rev")
        -- display dialog VolumeSize
        -- if VolumeSize >= "10" then
        do shell script "defaults write " & flagspath & " SelectedVolume " & selectedVolume
        -- else if VolumeSize < "10" then
        --     display alert "The selected Volume cannot be used to create a bootable installer." message "Please choose a volume at least 10GB or larger." & return & "(Error code: 1)"
        -- end if
    end SelectVolumePopUpClicked_
    
    on selectInstallerButton0Clicked_(sender)
        set InstallerPath to choose file with prompt "Please select a macOS or OS X Installer to process:" of type {"app"}
        set InstallerPath to POSIX path of InstallerPath
        
        set InstallerPath to (do shell script "echo " & InstallerPath & "| sed 's/ /\\\\ /g'")
        
        set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/openinstallercreatorflags.plist"
        do shell script "defaults write " & flagspath & " InstallerPath " & InstallerPath
        
        set valid to (do shell script "defaults read " & InstallerPath & "Contents/Info.plist CFBundleIconFile")
        if valid = "InstallAssistant" then
        else
        display alert "Fail to verify the selected Installer." message "This is not a macOS or OS X Installer. Please try again." & return & "(Error code: 2)"
        end if
    end selectInstallerButton0Clicked_
    
    on continueButton0Clicked_(sender)
        set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/openinstallercreatorflags.plist"
        set InstallerPath to (do shell script "defaults read " & flagspath & " InstallerPath")
        set OriginalInstallerPath to InstallerPath
        set InstallerPath to (do shell script "echo " & InstallerPath & "| sed 's/ /\\\\ /g' | rev | cut -c 2- | rev")
        set SelectedVolume to (do shell script "defaults read " & flagspath & " SelectedVolume")
        set SelectedVolume to (do shell script "echo " & SelectedVolume & "| sed 's/ /\\\\ /g'")
        set SelectedVolume to ("/Volumes/" & SelectedVolume)
        CreateNormalInstallMedia(InstallerPath,SelectedVolume,flagspath)
    end continueButton0Clicked_
    
    -----------------------------------------------------------------------------------
                                -- BASIC FUNCTIONS FOR EACH VIEW --
                                    
    on CreateNormalInstallMedia(InstallerPath,SelectedVolume,flagspath)

        -- Ask root permission
        progressText0's setStringValue: "Ask root permission"
        do shell script "echo" with administrator privileges
        
        -- Installer name
        progressText0's setStringValue: "Get installer name"
        delay 3
        set Installer_App_Name to (do shell script "basename " & InstallerPath)
        set Installer_App_Name_Partial to (do shell script "echo " & Installer_App_Name & " | rev | cut -c5- | rev")
        set Installer_SharedSupport_Path to InstallerPath & "/Contents/SharedSupport"
        
        -- Check installer structure
        progressText0's setStringValue: "Check structrue"
        delay 3
        do shell script "hdiutil attach " & Installer_SharedSupport_Path & "/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse" with administrator privileges
        set CheckStructure to (do shell script "defaults read " & flagspath & " CheckStructure")
        set StructureReturned to (do shell script CheckStructure)
        if StructureReturned = "tmp" then
            set Installer_Image_Path to "/tmp/InstallESD"
        else
            set Installer_Image_Path to Installer_SharedSupport_Path
        end if
        
        -- Mount BaseSystem.dmg
        progressText0's setStringValue: "Mount BaseSystem"
        delay 3
        do shell script "hdiutil attach " & Installer_Image_Path & "/BaseSystem.dmg -mountpoint /tmp/Base\\ System -nobrowse" with administrator privileges
        
        -- Check installer version
        progressText0's setStringValue: "Check installer version"
        delay 3
        set Installer_Version to (do shell script "defaults read /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion")
        set Installer_Version_Short to (do shell script "defaults read /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
        
        -- Erase Installer Volume
        progressText0's setStringValue: "Erase volume"
        delay 3
        do shell script "diskutil eraseVolume HFS+ " & (quoted form of Installer_App_Name_Partial) & " " & SelectedVolume with administrator privileges
        set Installer_Volume_Name to Installer_App_Name_Partial
        set Installer_Volume_Path to "/Volumes/" & Installer_Volume_Name
        
        -- Creating installer folders
        progressText0's setStringValue: "Create folders"
        set Installer_Volume_Path to quoted form of Installer_Volume_Path
        delay 3
        do shell script "mkdir -p " & Installer_Volume_Path & "/Library/Preferences/SystemConfiguration" with administrator privileges
        do shell script "mkdir -p " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        do shell script "mkdir -p " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
        
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "mkdir " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.9.", "10.10"} then
            do shell script "mkdir -p " & Installer_Volume_Path & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.12", "10.13", "10.14", "10.15"} then
            do shell script "mkdir -p " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
        end if
        
        -- Copy installer files
        progressText0's setStringValue: "Copy install files"
        delay 3
        do shell script "cp -R " & InstallerPath & " " & Installer_Volume_Path & "/" with administrator privileges
        
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/PlatformSupport.plist" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist" & " " & Installer_Volume_Path & "/.IABootFilesSystemVersion.plist" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.9.", "10.10"} then
            do shell script "cp /tmp/Base\\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache" & " " & Installer_Volume_Path & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.11", "10.12"} then
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.13", "10.14", "10.15"} then
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi*" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/bootbase.efi*" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/BridgeVersion.bin" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/immutablekernel*" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
            do shell script "cp -R /tmp/Base\\ System/usr/standalone/i386/SecureBoot.bundle" & " " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
        end if
        
        do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/PlatformSupport.plist" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        
        -- Create Installer Files
        progressText0's setStringValue: "Create install files"
        
            -- Implement a shell script later
        delay 3
        progressText0's setStringValue: "Write to plist"
        do shell script "echo " & Installer_Version_Short & " >> /tmp/installer_version_short" with administrator privileges
        do shell script "echo " & Installer_App_Name & " >> /tmp/installer_application_name" with administrator privileges
        do shell script "echo " & Installer_Volume_Path & " >> /tmp/installer_volume_path" with administrator privileges
        progressText0's setStringValue: "Create install files"
        
        -- Execute some shell scripts to create installer files over here...
        set createinstallfilessh to POSIX path of (path to current application as text) & "Contents/Resources/createinstallfiles.sh"
        do shell script "chmod +x " & createinstallfilessh with administrator privileges
        do shell script createinstallfilessh with administrator privileges
        do shell script "rm /tmp/installer*" with administrator privileges
        
            
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "cp " & Installer_Volume_Path & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
        end if
        
        do shell script "touch " & Installer_Volume_Path & "/.metadata_never_index" with administrator privileges
        
        progressText0's setStringValue: "Make bootable"
        delay 3
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "bless --folder " & Installer_Volume_Path & "/.IABootFiles --label " & Installer_Volume_Name with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.13", "10.14", "10.15"} then
            do shell script "bless --folder " & Installer_Volume_Path & "/System/Library/CoreServices --label " & Installer_Volume_Name with administrator privileges
        end if
        
        -- Unmount disk images
        progressText0's setStringValue: "Unmount disk images"
        delay 3
        do shell script "hdiutil detach /tmp/Base\\ System" with administrator privileges
        do shell script "hdiutil detach /tmp/InstallESD" with administrator privileges
        
        -- Making disk bootable
        
        progressText0's setStringValue: "Done"
        progressText0's setStringValue:"Done."
        -- The End.
        
    end CreateNormalInstallMedia
    
     -----------------------------------------------------------------------------------
                                -- STARTUP AND QUIT PROCESSES --
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        set VolumesList to (get paragraphs of (do shell script "ls /Volumes"))
        selectVolumePopUp0's addItemsWithTitles_(VolumesList)
        set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
        set selectedVolume to quoted form of selectedVolume
        
        set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/openinstallercreatorflags.plist"
        set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
        do shell script "defaults write " & flagspath & " SelectedVolume " & selectedVolume
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
    
end script
