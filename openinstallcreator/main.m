//
//  main.m
//  ProMacInstaller
//
//  Created by Ford on 4/2/20.
//  Copyright © 2020 MinhTon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
