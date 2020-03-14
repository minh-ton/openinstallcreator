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
    
    on downloadInstallerMenuClicked_(sender)
        
    end downloadInstallerMenuClicked_
    
    on browseInstaller_(sender)
        set macOSInstaller to choose file with prompt "Please select a macOS Installer to process:"
        set macOSInstaller to POSIX path of macOSInstaller
        do shell script "rm /tmp/CIMedia/InstallerPath.CIM"
        do shell script "echo " & macOSInstaller & " >> /tmp/CIMedia/InstallerPath.CIM"
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set InstallerlibSH to quoted form of (app_directory & "installerLIB.sh") as string
        do shell script "chmod +x " & InstallerlibSH
        do shell script InstallerlibSH
        set macOSInstaller to (do shell script "cat /tmp/CIMedia/InstallerPath.CIM")
        
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
    end browseInstaller_
    
    on selectVolumePopUpClicked_(sender)
        set TargetVolume to "/Volumes/" & (SelectVolumePopUp's titleOfSelectedItem() as text)
        do shell script "rm /tmp/CIMedia/TargetVolume.CIM"
        do shell script "echo " & TargetVolume & " >> /tmp/CIMedia/TargetVolume.CIM"
        set app_directory to POSIX path of (path to current application as text) & "Contents/Resources/"
        set VolumelibSH to quoted form of (app_directory & "volumeLIB.sh") as string
        do shell script "chmod +x " & VolumelibSH
        do shell script VolumelibSH
        set TargetVolume to (do shell script "cat /tmp/CIMedia/TargetVolume.CIM")
        
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
    end selectVolumePopUpClicked_
    
    on ContinueClicked_(sender)
        set CreatePatchedInstaller to (do shell script "cat /tmp/CIMedia/CIMFlags.CIM")
        set sharedSupportPath to (do shell script "cat /tmp/CIMedia/InstallerPath.CIM") & "Contents/SharedSupport"
        display dialog sharedSupportPath
        if CreatePatchedInstaller = "no" then
        end if
    end ContinueClicked_
    
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        set VolumesList to (get paragraphs of(do shell script "ls /Volumes"))
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
