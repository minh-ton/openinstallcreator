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
    
    on browseInstaller_(sender)
        set macOSInstaller to choose file with prompt "Please select a macOS Installer to process:"
        set macOSInstaller to POSIX path of macOSInstaller
        display dialog macOSInstaller
    end browseInstaller_
    
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        set VolumesList to (get paragraphs of (do shell script "ls /Volumes"))
        SelectVolumePopUp's addItemsWithTitles_(VolumesList)
        set username to (do shell script "whoami")
        statusText's setStringValue:"Welcome to macOS Installer Creator!" & return & return & "Please make sure that the targeted drive is backed up before being erased to make a bootable macOS Installer."
        progressLabel's setStringValue:"Ready!"
	end applicationWillFinishLaunching_
    
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
	
end script
