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
    property createNormalInstallersView : missing value
    property selectVolumePopUp0 : missing value
    property selectInstallerButton0 : missing value
    property progressBar0 : missing value
    property progressText0 : missing value
    property continueButton0 : missing value
    property continueText0 : missing value
    property statusText0 : missing value
    property readybutton0 : missing value
    
    -- View 4
    property downloadAppleInstallersView : missing value
    property selectOSVersionPopUp : missing value
    property continueButton1 : missing value
    property continueText1 : missing value
    property progressBar1 : missing value
    property statusText1 : missing value
    property progressText1 : missing value
    property readybutton1 : missing value
    property browseSaveFolder : missing value
    
   -----------------------------------------------------------------------------------
                        --  FIRST VIEW  -  NORMAL BOOTABLE INSTALLER --
   
    on SelectVolumePopUp0Clicked_(sender)
        set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
        set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
        set flagspath to "/tmp/openinstallercreatorflags.plist"
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
        statusText0's setStringValue:"Now, please select the I'm ready button to continue."
        set InstallerPath to (do shell script "echo " & InstallerPath & "| sed 's/ /\\\\ /g'")
        
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        do shell script "defaults write " & flagspath & " InstallerPath " & InstallerPath
        
        set valid to (do shell script "defaults read " & InstallerPath & "Contents/Info.plist CFBundleIconFile")
        if valid = "InstallAssistant" then
        else
        display alert "Fail to verify the selected Installer." message "This is not a macOS or OS X Installer. Please try again." & return & "(Error code: 2)"
        end if
    end selectInstallerButton0Clicked_
    
    on readybutton0Clicked_(sender)
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set InstallerPath to (do shell script "defaults read " & flagspath & " InstallerPath")
        if InstallerPath = "unavailable" then
            display alert "Installer Unavailable for Creation Process." message "Oops... Seems like you forgot to choose an Installer." & return & "(Error code: 3)"
        else
            continueButton0's setEnabled_(true)
            selectVolumePopUp0's setEnabled_(false)
            selectInstallerButton0's setEnabled_(false)
            readybutton0's setEnabled_(false)
            statusText0's setStringValue:"Press the Continue button to start the creation process."
        end if
    end readybutton0Clicked_
    
    on continueButton0Clicked_(sender)
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set InstallerPath to (do shell script "defaults read " & flagspath & " InstallerPath")
        set OriginalInstallerPath to InstallerPath
        set InstallerPath to (do shell script "echo " & InstallerPath & "| sed 's/ /\\\\ /g' | rev | cut -c 2- | rev")
        set SelectedVolume to (do shell script "defaults read " & flagspath & " SelectedVolume")
        set SelectedVolume to (do shell script "echo " & SelectedVolume & "| sed 's/ /\\\\ /g'")
        set SelectedVolume to ("/Volumes/" & SelectedVolume)
        statusText0's setStringValue:"openinstallcreator is creating a Bootable macOS/OS X Installer..."
        CreateNormalInstallMedia(InstallerPath,SelectedVolume,flagspath)
    end continueButton0Clicked_
    
    on AboutButtonClicked_(sender)
        set theController to current application's class "NSWindowController"'s alloc()'s init()
        current application's class "NSBundle"'s loadNibNamed:"About" owner:theController
    end AboutButtonClicked_
    
    -----------------------------------------------------------------------------------
                        -- FOURTH VIEW - DOWNLOAD APPLE INSTALLERS --
    
    on selectOSVersionPopUpClicked_(sender)
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set SelectedOSVersion to ((selectOSVersionPopUp's indexOfSelectedItem()) as string) as integer
        do shell script "defaults write " & flagspath & " SelectedOSVersion " & SelectedOSVersion
    end selectOSVersionPopUpClicked_
    
    on browseSaveFolderClicked_(sender)
        set SavePath to choose folder with prompt "Please select a folder to save the Installer:"
        set SavePath to POSIX path of SavePath
        set SavePath to quoted form of SavePath
        set writable to do shell script "test -w " & SavePath & "; echo $?"
        if writable = "1" then
            display alert "Destination is not writable." message "Please choose a writable folder." & return & "(Error code: 5)"
        else if writable = "0" then
            set flagspath to "/tmp/openinstallercreatorflags.plist"
            do shell script "defaults write " & flagspath & " SavePath " & SavePath
        end if
    end browseSaveFolderClicked_
    
    on readybutton1Clicked_(sender)
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set SavePath to (do shell script "defaults read " & flagspath & " SavePath")
        if SavePath = "unavailable" then
            display alert "No destination folder has been specified." message "Well, just try to click the Folder Icon and browse for a folder to save the downloaded macOS/OS X Installer." & return & "(Error code: 4)"
        else
            selectOSVersionPopUp's setEnabled_(false)
            readybutton1's setEnabled_(false)
            browseSaveFolder's setEnabled_(false)
            continueButton1's setEnabled_(true)
            statusText1's setStringValue:"Now, please select the I'm ready button to continue."
        end if
    end readybutton1Clicked_
    
    on continueButton1Clicked_(sender)
        statusText1's setStringValue:"openinstallcreator is downloading an Apple macOS/OS X Installer..."
        downloadAppleInstallers()
    end continueButton1Clicked_
    
    -----------------------------------------------------------------------------------
                                -- BASIC FUNCTIONS FOR EACH VIEW --
                                    
    on CreateNormalInstallMedia(InstallerPath,SelectedVolume,flagspath)
        
        progressText0's setHidden_(false)
        readybutton0's setHidden_(true)
        continueButton0's setEnabled_(false)
        
        -- Ask root permission
        progressText0's setStringValue: "Step 1 of 11: Starting Helper..."
        delay 3
        do shell script "echo" with administrator privileges
        
        -- Installer name
        progressText0's setStringValue: "Step 2 of 11: Unpacking Installer..."
        delay 3
        set Installer_App_Name to (do shell script "basename " & InstallerPath)
        set Installer_App_Name_Partial to (do shell script "echo " & Installer_App_Name & " | rev | cut -c5- | rev")
        set Installer_SharedSupport_Path to InstallerPath & "/Contents/SharedSupport"
        tell progressBar0 to setDoubleValue:5
        
        -- Check installer structure
        progressText0's setStringValue: "Step 3 of 11: Checking Installer Structure..."
        delay 3
        do shell script "hdiutil attach " & Installer_SharedSupport_Path & "/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse" with administrator privileges
        set CheckStructure to (do shell script "defaults read " & flagspath & " CheckStructure")
        set StructureReturned to (do shell script CheckStructure)
        if StructureReturned = "tmp" then
            set Installer_Image_Path to "/tmp/InstallESD"
        else
            set Installer_Image_Path to Installer_SharedSupport_Path
        end if
        tell progressBar0 to setDoubleValue:10
        
        -- Mount BaseSystem.dmg
        progressText0's setStringValue: "Step 4 of 11: Mounting BaseSystem.dmg"
        delay 3
        do shell script "hdiutil attach " & Installer_Image_Path & "/BaseSystem.dmg -mountpoint /tmp/Base\\ System -nobrowse" with administrator privileges
        tell progressBar0 to setDoubleValue:20

        -- Check installer version
        progressText0's setStringValue: "Step 5 of 11: Reading Installer Version..."
        delay 3
        set Installer_Version to (do shell script "defaults read /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion")
        set Installer_Version_Short to (do shell script "defaults read /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
        tell progressBar0 to setDoubleValue:25
        
        -- Erase Installer Volume
        progressText0's setStringValue: "Step 6 of 11: Erasing Installer Volume..."
        delay 3
        do shell script "diskutil eraseVolume HFS+ " & (quoted form of Installer_App_Name_Partial) & " " & SelectedVolume with administrator privileges
        set Installer_Volume_Name to Installer_App_Name_Partial
        set Installer_Volume_Path to "/Volumes/" & Installer_Volume_Name
        tell progressBar0 to setDoubleValue:35
        
        -- Creating installer folders
        progressText0's setStringValue: "Step 7 of 11: Creating Installer Folders..."
        delay 3
        set Installer_Volume_Path to quoted form of Installer_Volume_Path
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
        tell progressBar0 to setDoubleValue:40
        
        -- Copy installer files
        progressText0's setStringValue: "Step 8 of 11: Copying Installer Files..."
        delay 3
        
        with timeout of 86400 seconds
            try
                do shell script "cp -R " & InstallerPath & " " & Installer_Volume_Path & "/" with administrator privileges
                tell progressBar0 to setDoubleValue:55
            end try
        end timeout
        
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/PlatformSupport.plist" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist" & " " & Installer_Volume_Path & "/.IABootFilesSystemVersion.plist" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
        end if
        delay 1
        tell progressBar0 to setDoubleValue:58
        
        if Installer_Version_Short is in {"10.9.", "10.10"} then
            do shell script "cp /tmp/Base\\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache" & " " & Installer_Volume_Path & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
        end if
        delay 1
        tell progressBar0 to setDoubleValue:60
        
        if Installer_Version_Short is in {"10.11", "10.12"} then
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
        end if
        delay 1
        tell progressBar0 to setDoubleValue:63
        
        if Installer_Version_Short is in {"10.13", "10.14", "10.15"} then
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi*" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/bootbase.efi*" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/BridgeVersion.bin" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
            do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/immutablekernel*" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
            do shell script "cp -R /tmp/Base\\ System/usr/standalone/i386/SecureBoot.bundle" & " " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
        end if
        delay 1
        tell progressBar0 to setDoubleValue:65
        
        do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/PlatformSupport.plist" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
        delay 1
        tell progressBar0 to setDoubleValue:70
        
        -- Create Installer Files
        progressText0's setStringValue: "Step 9 of 11: Creating Installer Boot Files..."
        delay 3
        do shell script "echo " & Installer_Version_Short & " >> /tmp/installer_version_short" with administrator privileges
        do shell script "echo " & Installer_App_Name & " >> /tmp/installer_application_name" with administrator privileges
        do shell script "echo " & Installer_Volume_Path & " >> /tmp/installer_volume_path" with administrator privileges
        set createinstallfilessh to POSIX path of (path to current application as text) & "Contents/Resources/createinstallfiles.sh"
        do shell script "chmod +x " & createinstallfilessh with administrator privileges
        do shell script createinstallfilessh with administrator privileges
        do shell script "rm /tmp/installer*" with administrator privileges
        tell progressBar0 to setDoubleValue:75
        
            
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "cp " & Installer_Volume_Path & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
        end if
        
        do shell script "touch " & Installer_Volume_Path & "/.metadata_never_index" with administrator privileges
        tell progressBar0 to setDoubleValue:80
        
        -- Making disk bootable
        
        progressText0's setStringValue: "Step 10 of 11: Making Installer Bootable..."
        delay 3
        if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
            do shell script "bless --folder " & Installer_Volume_Path & "/.IABootFiles --label " & Installer_Volume_Name with administrator privileges
        end if
        
        if Installer_Version_Short is in {"10.13", "10.14", "10.15"} then
            do shell script "bless --folder " & Installer_Volume_Path & "/System/Library/CoreServices --label " & Installer_Volume_Name with administrator privileges
        end if
        do shell script "chflags hidden " & Installer_Volume_Path & "/System" with administrator privileges
        do shell script "chflags hidden " & Installer_Volume_Path & "/Library" with administrator privileges
        do shell script "chflags hidden " & Installer_Volume_Path & "/usr" with administrator privileges
        
        set CatalinaICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Catalina.icns"
        set MojaveICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Mojave.icns"
        set HighSierraICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/HighSierra.icns"
        set SierraICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Sierra.icns"
        set ElCapitanICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/ElCapitan.icns"
        set YosemiteICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Yosemite.icns"
        set MavericksICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Mavericks.icns"
        
        if Installer_Version_Short = "10.10" then
            do shell script "cp " & YosemiteICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        else if Installer_Version_Short = "10.11" then
            do shell script "cp " & ElCapitanICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        else if Installer_Version_Short = "10.12" then
            do shell script "cp " & SierraICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        else if Installer_Version_Short = "10.13" then
            do shell script "cp " & HighSierraICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        else if Installer_Version_Short = "10.14" then
            do shell script "cp " & MojaveICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        else if Installer_Version_Short = "10.15" then
            do shell script "cp " & CatalinaICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        else if Installer_Version_Short = "10.9." then
            do shell script "cp " & MavericksICNS & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
        end if
        
        tell progressBar0 to setDoubleValue:90
        
        -- Unmount disk images
        progressText0's setStringValue: "Step 11 of 11: Unmounting Disk Images..."
        do shell script "hdiutil detach /tmp/Base\\ System" with administrator privileges
        do shell script "hdiutil detach /tmp/InstallESD" with administrator privileges
        
        
        tell progressBar0 to setDoubleValue:100
        progressText0's setStringValue: "Operation Completed."
        display notification "Successfully created an " & Installer_Volume_Name & " Bootable Installer." with title "openinstallcreator" sound name "Opening"
        -- The End.
        
    end CreateNormalInstallMedia
    
    on downloadAppleInstallers()
        
        delay 3
        progressText1's setStringValue: "Starting helper..."
        progressBar1's setHidden_(false)
        progressBar1's startAnimation:me
        continueButton1's setEnabled_(false)
        readybutton1's setHidden_(true)
        progressText1's setHidden_(false)
        
        delay 3
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set SavePath to (do shell script "defaults read " & flagspath & " SavePath")
        set OriginalSavePath to SavePath
        set SavePath to (do shell script "echo " & SavePath & "| sed 's/ /\\\\ /g' | rev | cut -c 2- | rev")
        set SelectedOSVersion to (do shell script "defaults read " & flagspath & " SelectedOSVersion")
        
        -- Check system version
        progressText1's setStringValue: "Reading System Version..."
        delay 3
        set Volume_Version to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion")
        set Volume_Version_Short to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
        set Volume_Build to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductBuildVersion")
        
        -- Check curl version (10.7)
        if Volume_Version_Short = "10.7." then
            progressText1's setStringValue: "Checking Curl Version..."
            delay 3
            set CheckCurl to (do shell script "defaults read /tmp/openinstallercreatorflags.plist CheckCurl")
            set CurlCompatibility to (do shell script CheckCurl)
            if CurlCompatibility = "incompatible" then
                display alert "Curl version check failed." message "This version of OS X requires Xcode Command Line Tools, MacPorts, and curl updates to be manually installed."
                try
                    error number -128
                end try
            end if
        end if
        
        if Volume_Version_Short = "10.7." then
            set Curl to "/opt/local/bin/curl"
            else
            set Curl to "curl"
        end if
        
        -- Check internet connection
        progressText1's setStringValue: "Checking Internet Connection..."
        delay 3
        repeat with i from 1 to 2
            try
                do shell script "ping -o -t 2 www.google.com"
                exit repeat
                on error
                if i = 2 then
                    display alert "No Internet Connection" message "Please connect to the Internet to download the Installer."
                    error number -128
                end if
            end try
        end repeat

        -- Prepare resources
        progressText1's setStringValue: "Preparing Resources..."
        delay 3
        set pbzx to POSIX path of (path to current application as text) & "Contents/Resources/pbzx"
        try
            do shell script "cp " & pbzx & " /tmp"
            do shell script "chmod +x /tmp/pbzx"
            on error
            display alert "Failed to prepare resources" message "(Error code: 6)"
        end try
        
        -- Input Installer Version
        progressText1's setStringValue: "Preparing Catalog..."
        delay 3
        try
        if SelectedOSVersion = "0" then
            set Installer_URL to "53/58/061-96006-A_D2HTVCGUD8/gdt4thee08sjbckqx4p9efpww12qgz3w98"
            set Installer_Name to "Install macOS Catalina"
            set InstallerVer to "10.15"
        end if
        
        if SelectedOSVersion = "1" then
            set Installer_URL to "17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el"
            set Installer_Name to "Install macOS Mojave"
            set InstallerVer to "10.14"
        end if
        
        if SelectedOSVersion = "2" then
            set Installer_URL to "06/50/041-91758-A_M8T44LH2AW/b5r4og05fhbgatve4agwy4kgkzv07mdid9"
            set Installer_Name to "Install macOS High Sierra"
            set InstallerVer to "10.13"
        end if
            
        if SelectedOSVersion = "3" then
            set Installer_URL to "http://updates-http.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg"
            set Installer_Name to "Install macOS Sierra"
            set InstallerVer to "10.12"
        end if
        
        if SelectedOSVersion = "4" then
            set Installer_URL to "http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg"
            set Installer_Name to "Install OS X El Capitan"
            set InstallerVer to "10.11"
        end if
    
        if SelectedOSVersion = "5" then
            set Installer_URL to "http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg"
            set Installer_Name to "Install OS X Yosemite"
            set InstallerVer to "10.10"
        end if
        
        on error
        display alert "Failed to Prepare Catalog." message "(Error code: 7)"
        end try
    
        delay 3
        do shell script "mkdir /tmp/" & (quoted form of Installer_Name)
        
        
        -- Download & Prepare Installer
        progressText1's setStringValue: "Downloading Installer..."
        delay 3
        if InstallerVer is in {"10.13", "10.14", "10.15"} then
            
            -- Download InstallAssistantAuto.pkg
            try
            progressText1's setStringValue: "Downloading InstallAssistantAuto.pkg..."
            delay 3
            do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/InstallAssistantAuto.pkg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/InstallAssistantAuto.pkg"
            on error
                do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                do shell script "rm /tmp/pbzx"
                display alert "Failed to download InstallAssistantAuto.pkg" message "(Error code: 8)"
            end try
            
            -- Download AppleDiagnostics.chunklist
            try
            progressText1's setStringValue: "Downloading AppleDiagnostics.chunklist..."
            delay 3
            do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.chunklist http://swcdn.apple.com/content/downloads/" & Installer_URL & "/AppleDiagnostics.chunklist"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to download AppleDiagnostics.chunklist" message "(Error code: 8)"
            end try
            
            -- Download AppleDiagnostics.dmg
            try
            progressText1's setStringValue: "Downloading AppleDiagnostics.dmg..."
            delay 3
            do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.dmg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/AppleDiagnostics.dmg"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to download AppleDiagnostics.dmg" message "(Error code: 8)"
            end try
            
            -- Download BaseSystem.chunklist
            try
            progressText1's setStringValue: "Downloading BaseSystem.chunklist..."
            delay 3
            do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.chunklist http://swcdn.apple.com/content/downloads/" & Installer_URL & "/BaseSystem.chunklist"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to download BaseSystem.chunklist" message "(Error code: 8)"
            end try
            
            -- Download BaseSystem.dmg
            with timeout of 86400 seconds
                try
                    progressText1's setStringValue: "Downloading BaseSystem.dmg..."
                    delay 3
                    do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.dmg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/BaseSystem.dmg"
                    on error
                    do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                    do shell script "rm /tmp/pbzx"
                    display alert "Failed to download BaseSystem.dmg" message "(Error code: 8)"
                end try
            end timeout
            
            -- Download InstallESD.dmg
            progressText1's setStringValue: "Downloading InstallESD.dmg..."
            with timeout of 86400 seconds
                try
                    delay 3
                    do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/InstallESD.dmg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/InstallESDDmg.pkg"
                    on error
                    do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                    do shell script "rm /tmp/pbzx"
                    display alert "Failed to download InstallESD.dmg" message "(Error code: 8)"
                end try
            end timeout
            
            -- Prepare Installer
            progressText1's setStringValue: "Extracting Installer from Package..."
            try
            delay 3
            do shell script "cd /tmp/" & (quoted form of Installer_Name) & " && /tmp/pbzx /tmp/" & (quoted form of Installer_Name) & "/InstallAssistantAuto.pkg | cpio -i"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to extract Installer from Package." message "(Error code: 9)"
            end try
            
            progressText1's setStringValue: "Copying Files to Destination..."
            try
            delay 3
            do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_Name) & ".app " & SavePath
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to copy Installer to destination." message "(Error code: 9)"
            end try
            
            progressText1's setStringValue: "Copying AppleDiagnostics.chunklist to Destination..."
            try
            delay 3
            do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.chunklist " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to copy AppleDiagnostics.chunklist." message "(Error code: 9)"
            end try
            
            progressText1's setStringValue: "Copying AppleDiagnostics.dmg to Destination..."
            try
            delay 3
            do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.dmg " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to copy AppleDiagnostics.dmg." message "(Error code: 9)"
            end try
            
            progressText1's setStringValue: "Copying BaseSystem.chunklist to Destination..."
            try
            delay 3
            do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.chunklist " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to copy BaseSystem.chunklist." message "(Error code: 9)"
            end try
            
            progressText1's setStringValue: "Copying BaseSystem.dmg to Destination..."
            with timeout of 86400 seconds
                try
                    delay 3
                    do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.dmg " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
                    on error
                    do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                    do shell script "rm /tmp/pbzx"
                    display alert "Failed to copy BaseSystem.dmg." message "(Error code: 9)"
                end try
            end timeout
            
            progressText1's setStringValue: "Copying InstallESD.dmg to Destination..."
            with timeout of 86400 seconds
                try
                    delay 3
                    do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/InstallESD.dmg " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
                    on error
                    do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                    do shell script "rm /tmp/pbzx"
                    display alert "Failed to copy InstallESD.dmg." message "(Error code: 9)"
                end try
            end timeout
        
        end if

        if InstallerVer is in {"10.12", "10.11", "10.10"} then
            
            -- Download InstallOS.dmg
            progressText1's setStringValue: "Downloading InstallOS.dmg..."
            with timeout of 86400 seconds
                try
                    delay 3
                    do shell script Curl & " -L -s -o /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_Name & ".dmg") & " " & Installer_URL
                    on error
                    do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                    do shell script "rm /tmp/pbzx"
                    display alert "Failed to download InstallOS.dmg" message "(Error code: 8)"
                end try
            end timeout
            
            -- Prepare Installer
            progressText1's setStringValue: "Mounting Disk Image..."
            delay 3
            try
            do shell script "hdiutil attach /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_Name & ".dmg") & " -mountpoint /tmp/" & (quoted form of Installer_Name & "_dmg") & " -nobrowse"
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to mount InstallOS.dmg." message "(Error code: 10)"
            end try
            
            set Installer_PKG to (do shell script "ls /tmp/" & (quoted form of Installer_Name & "_dmg"))
            set Installer_PKG_Partial to (do shell script "echo " & (quoted form of Installer_PKG) & " | cut -f1 -d.")
            
            progressText1's setStringValue: "Expanding Packages..."
            try
            delay 3
            do shell script "pkgutil --expand /tmp/" & (quoted form of Installer_Name & "_dmg") & "/" & (quoted form of Installer_PKG) & " /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_PKG_Partial)
            do shell script "tar -xf /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_PKG_Partial) & "/" & (quoted form of Installer_PKG) & "/Payload -C " & SavePath
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to expand Installer Packages." message "(Error code: 9)"
            end try
            
            progressText1's setStringValue: "Copying InstallESD.dmg to Destination..."
            with timeout of 86400 seconds
                try
                    delay 3
                    do shell script "cp /tmp/" & (quoted form of Installer_Name & "_dmg") & "/" & (quoted form of Installer_PKG) & " " & SavePath & "/" & (quoted form of Installer_Name & ".app") & "/Contents/SharedSupport/InstallESD.dmg"
                    on error
                    do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
                    do shell script "rm /tmp/pbzx"
                    display alert "Failed to copy InstallESD.dmg." message "(Error code: 9)"
                end try
            end timeout
            
            progressText1's setStringValue: "Unmounting Disk Image..."
            try
            delay 3
            do shell script "hdiutil detach /tmp/" & (quoted form of Installer_Name & "_dmg")
            on error
            do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
            do shell script "rm /tmp/pbzx"
            display alert "Failed to unmount InstallOS.dmg." message "(Error code: 10)"
            end try
        end if
        
        -- Remove temporary files
        progressText1's setStringValue: "Removing Temporary Files..."
        delay 3
        do shell script "rm -R /tmp/" & (quoted form of Installer_Name)
        do shell script "rm /tmp/pbzx"
        progressText1's setStringValue: "Operation Completed."
        progressBar1's stopAnimation:me

    end downloadAppleInstallers
    
    -------------------------------------------------------------------------------------
                                -- SIDE BAR ACTIONS --
                                
    on createNormalInstallersViewClicked_(sender)
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set View1Status to (do shell script "defaults read " & flagspath & " View1Status")
        set View4Status to (do shell script "defaults read " & flagspath & " View4Status")
        if View4Status = "1" then
            downloadAppleInstallersView's setHidden_(true)
            createNormalInstallersView's setHidden_(false)
            set ViewStatus to "0"
            do shell script "defaults write " & flagspath & " View4Status " & ViewStatus
            set ViewStatus to "1"
            do shell script "defaults write " & flagspath & " View1Status " & ViewStatus
        end if
    end createNormalInstallersViewClicked_
    
    on downloadAppleInstallersViewClicked_(sender) -- Only for 10.7
        set flagspath to "/tmp/openinstallercreatorflags.plist"
        set View1Status to (do shell script "defaults read " & flagspath & " View1Status")
        set View4Status to (do shell script "defaults read " & flagspath & " View4Status")
        if View1Status = "1" then
            createNormalInstallersView's setHidden_(true)
            downloadAppleInstallersView's setHidden_(false)
            progressBar1's setHidden_(true)
            set SelectedOSVersion to ((selectOSVersionPopUp's indexOfSelectedItem()) as string) as integer
            do shell script "defaults write " & flagspath & " SelectedOSVersion " & SelectedOSVersion
            do shell script "defaults write " & flagspath & " SavePath unavailable"
            set ViewStatus to "0"
            do shell script "defaults write " & flagspath & " View1Status " & ViewStatus
            set ViewStatus to "1"
            do shell script "defaults write " & flagspath & " View4Status " & ViewStatus
        end if
    end downloadAppleInstallersViewClicked_
    
    ------------------------------------------------------------------------------------
                                -- MENU BAR ACTIONS --
      
      on AboutMenuClicked_(sender)
          set theController to current application's class "NSWindowController"'s alloc()'s init()
          current application's class "NSBundle"'s loadNibNamed:"About" owner:theController
      end AboutMenuClicked_
        
     -----------------------------------------------------------------------------------
                                -- STARTUP AND QUIT PROCESSES --
	
	on applicationWillFinishLaunching_(aNotification)
        
        -- First view (createnormalbootableinstaller)
        set VolumesList to (get paragraphs of (do shell script "ls /Volumes"))
        selectVolumePopUp0's addItemsWithTitles_(VolumesList)
        set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
        set selectedVolume to quoted form of selectedVolume
        
        set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/openinstallercreatorflags.plist"
        do shell script "cp " & flagspath & " /tmp"
        
        set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
        do shell script "defaults write " & flagspath & " SelectedVolume " & selectedVolume
        set InstallerPath to "unavailable"
        do shell script "defaults write " & flagspath & " InstallerPath " & InstallerPath
        
        -- View controllers
        set ViewStatus to "1"
        do shell script "defaults write " & flagspath & " View1Status " & ViewStatus
        progressText0's setHidden_(true)
        continueButton0's setEnabled_(false)
        downloadAppleInstallersView's setHidden_(true)
        
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        do shell script "rm /tmp/openinstallercreatorflags.plist"
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
    
end script
