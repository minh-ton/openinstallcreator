# [openinstallcreator beta](https://github.com/Minh-Ton/openinstallcreator)
An open-source AppleScriptObj-C application allows you to make a bootable macOS/OS X Installer... and more.

<img src="https://github.com/Minh-Ton/openinstallcreator/raw/master/Resources/imac27.png" width="256"> 

## Requirements
- Minimum requirement: OS X 10.6 Snow Leopard and newer (requires OS X 10.7 or newer to download Installers).
- Supported Installers: OS X 10.9 Mavericks to macOS 10.15 Catalina.
- USB/Disk size: ***At least 8GB for OS X 10.9 to macOS 10.14; 10GB for macOS 10.15 Catalina.***

## Download
- Download latest version: [Download](https://github.com/Minh-Ton/openinstallcreator/releases) (beta 3)
- Download source code: [Download](https://github.com/Minh-Ton/openinstallcreator/archive/master.zip) (beta 3)

## Additional features
- The created Bootable Installer will have an Icon (shown in Boot Manager) base on the version of the Installer.

## Sidenotes
- ***Do not use "Download Apple Installers" feature under OS X 10.6 (The feature isn't fully implemented yet).***
- ***If you force close the app, you will have to go to `/tmp` and delete `openinstallcreatorflags.plist`, `pbzx`, and `Install macOS/OS X`.***

## Known issues
- The app often fails to download/prepare the macOS 10.15 Catalina Installer. The issue hasn't been investigated yet. 

## AppleScriptObj-C Limitations
- When the app is running in the background, it won't show the GUI when clicked onto the Dock Icon. A workaround for this is to **_secondary click_** the openinstallcreator Dock Icon, then choose **_"Show All Window"_**.
- While the app is doing some heavy tasks, such as `Create Bootable Installer` or `Download Apple Installer`, the *"spinning rainbow cursor"* will appeared when hovering the cursor on the application GUI. *(It's still doing it work though, just because there are so many tasks that's being added to the queue, making the queue banked up)*.

## Screenshot (beta 3)

<img src="https://github.com/Minh-Ton/openinstallcreator/raw/master/Screenshots/openinstallcreator.png" width="512"> 
<img src="https://github.com/Minh-Ton/openinstallcreator/raw/master/Screenshots/openinstallcreator2.png" width="512"> 

