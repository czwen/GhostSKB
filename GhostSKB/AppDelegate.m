//
//  AppDelegate.m
//  testApp
//
//  Created by 丁明信 on 4/4/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import "AppDelegate.h"
#import "GHDefaultManager.h"
#import "GHKeybindingManager.h"
#import "GHInputSourceManager.h"
#import "Constant.h"

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>

static double switchDelay;

@interface AppDelegate ()

- (void)updateProfilesMenu:(NSMenu *)menu;
- (NSArray *)sortProfileNames:(NSArray *)profiles;
@end


@implementation AppDelegate
@synthesize preferenceController;

#pragma mark - App Life Cycle

static void notificationCallback (CFNotificationCenterRef center,
                           void * observer,
                           CFStringRef name,
                           const void * object,
                           CFDictionaryRef userInfo) {
    [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_INPUT_SOURCE_LIST_CHANGED object:NULL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc addObserver:self selector:@selector(handleAppActivateNoti:) name:NSWorkspaceDidActivateApplicationNotification object:NULL];
    [nc addObserver:self selector:@selector(handleAppUnhideNoti:) name:NSWorkspaceDidUnhideApplicationNotification object:NULL];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(handleGHAppSelectedNoti:) name:GH_NK_APP_SELECTED object:NULL];
    [notiCenter addObserver:self selector:@selector(profileListChanged) name:GH_NK_PROFILE_LIST_CHANGED object:NULL];
    [notiCenter addObserver:self selector:@selector(profileRenamed:) name:GH_NK_PROFILE_RENAME object:NULL];
    [notiCenter addObserver:self selector:@selector(defaultProfileChanged:) name:GH_NK_DEFAULT_PROFILE_CHANGED object:NULL];
    [notiCenter addObserver:self selector:@selector(delayTimeChanged:) name:GH_NK_DELAY_TIME_CHANGED object:NULL];
    [notiCenter addObserver:self selector:@selector(icloudSyncingOk:) name:GH_NK_ICLOUD_DOWNLOAD_SYNCING_OK object:NULL];
    [GHInputSourceManager getInstance];
    [GHDefaultManager getInstance];
    [[GHKeybindingManager getInstance] setProfileHotKeys:[[GHDefaultManager getInstance] getDefaultProfileName]];
    
    //observing change of input source list
    CFNotificationCenterRef cfnCenter = CFNotificationCenterGetDistributedCenter();
    CFNotificationCenterAddObserver(cfnCenter, NULL, notificationCallback, kTISNotifyEnabledKeyboardInputSourcesChanged, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    [self initStatusItem];
    
    switchDelay = [[GHDefaultManager getInstance] getDelayTime];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //再次点击的时候显示icon
    [statusItem setVisible:true];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)awakeFromNib {
    [imenu setDelegate:self];
}


+ (BOOL)isSystemCurrentDarkMode {
    NSDictionary *globalPersistentDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    @try {
        NSString *interfaceStyle = [globalPersistentDomain valueForKey:@"AppleInterfaceStyle"];
        return [interfaceStyle isEqualToString:@"Dark"];
    }
    @catch (NSException *exception) {
        return NO;
    }
}

- (NSArray *)sortProfileNames:(NSArray *)profiles {
    NSArray *newProfiles = [profiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = (NSString *)obj1;
        NSString *str2 = (NSString *)obj2;
        return [str1 compare:str2];
    }];
    return newProfiles;
}

- (void)refreshMenu {
    NSMenu *menu = statusItem.menu;
    for (NSMenuItem *item in menu.itemArray) {
        if ([item.title isEqualToString:@""] || item.title == NULL) {
            break;
        }
        [menu removeItem:item];
    }
    
    [self updateProfilesMenu:menu];
}

- (void)initStatusItem {
    statusItemSelected = false;
    NSString *imageName = @"ghost_dark_small";
    NSImage *normalImage = [NSImage imageNamed:imageName];
    [normalImage setTemplate:YES];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = normalImage;
    
    //menus
    NSMenu *menu = [[NSMenu alloc] init];
    [self updateProfilesMenu:menu];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Preference..." action:@selector(showPreference) keyEquivalent:@","]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Disable GhostSKB" action:@selector(toggleGhostSKB:) keyEquivalent:@""]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Hide Menu Bar Icon" action:@selector(hideMenuBarIcon:) keyEquivalent:@""]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit GhostSKB" action:@selector(quitGhostSKB) keyEquivalent:@"Q"]];
    statusItem.menu = menu;
    
    [statusItem.button setAction:@selector(onStatusItemSelected:)];
}



- (void)updateProfilesMenu:(NSMenu *)menu {
    NSArray *profiles = [[GHDefaultManager getInstance] getProfileList];
    profiles = [self sortProfileNames:profiles];
    NSString *defaultProfile = [[GHDefaultManager getInstance] getDefaultProfileName];
    for (NSInteger i=0; i<[profiles count]; i++) {
        NSString *profileName = (NSString *)[profiles objectAtIndex:i];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:profileName action:@selector(chooseProfile:) keyEquivalent:@""];
        [menu insertItem:item atIndex:i];
        if([profileName isEqualToString:defaultProfile]) {
            [item setState:NSOnState];
        }
        else {
            [item setState:NSOffState];
        }
    }
}


#pragma mark - Notifications
- (void)icloudSyncingOk:(NSNotification *)notification {
    [self refreshMenu];
}

- (void)delayTimeChanged:(NSNotification *)notification {
    switchDelay = [[GHDefaultManager getInstance] getDelayTime];
}
- (void)profileListChanged {
    [self refreshMenu];
}

- (void)profileRenamed:(NSNotification *)notification {
    NSDictionary *info = [notification object];
    NSString *origin = [info objectForKey:@"origin"];
    NSString *new = [info objectForKey:@"new"];
    NSMenu *menu = statusItem.menu;
    for (NSMenuItem *item in menu.itemArray) {
        if ([item.title isEqualToString:origin]) {
            item.title = new;
            break;
        }
    }
}

- (void)defaultProfileChanged:(NSNotification *)notification {
    NSString *profileName = [notification object];
    NSMenu *menu = statusItem.menu;
    for (NSMenuItem *item in menu.itemArray) {
        if (item.title == NULL || [item.title length] == 0) {
            break;
        }
        NSControlStateValue value = [profileName isEqualToString:item.title] ? NSOnState : NSOffState;
        item.state = value;
    }
    
}

-(void)darkModeChanged:(NSNotification *)notification {
    
}

- (void) handleGHAppSelectedNoti:(NSNotification *)noti {
    //get forcus
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (void) handleAppUnhideNoti:(NSNotification *)noti {
    NSRunningApplication *runningApp = (NSRunningApplication *)[noti.userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString *identifier = runningApp.bundleIdentifier;
    [self changeInputSourceForApp:identifier];
}

- (void) handleAppActivateNoti:(NSNotification *)noti {
    NSRunningApplication *runningApp = (NSRunningApplication *)[noti.userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString *identifier = runningApp.bundleIdentifier;
    [self changeInputSourceForApp:identifier];
}


#pragma mark - MenuItem Actions

- (void)chooseProfile:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    [[GHDefaultManager getInstance] changeDefaultProfile:item.title];
    [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_DEFAULT_PROFILE_CHANGED object:item.title];
}

- (void)hideMenuBarIcon:(id)sender {
    [statusItem setVisible:FALSE];
}

- (void)toggleGhostSKB:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    if ([sender respondsToSelector:@selector(setState:)]) {
        NSControlStateValue state = NSOnState;
        if (item.state == NSOnState) {
            state = NSOffState;
        }
        [item setState:state];
    }

    //TODO handle enable or disable status
}

- (void)quitGhostSKB {
    [NSApp terminate:self];
}

- (void)showPreference {
    NSStoryboard *board = [NSStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    if (preferenceController == NULL) {
        preferenceController = [board instantiateInitialController];
    }
    [preferenceController showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}


- (void) onStatusItemSelected:(id) sender {
    statusItemSelected = !statusItemSelected;
}

- (void) changeStatusItemImage:(BOOL)isLight {
    if (isLight) {
        statusItem.image = [NSImage imageNamed:@"ghost_white_small"];
    }
    else {
        statusItem.image =[NSImage imageNamed:@"ghost_dark_small"];
    }
}


#pragma mark - Core Methods

- (void)changeInputSource:(NSString *)inputId {
     [self performSelector:@selector(doChangeInputSource:) withObject:inputId afterDelay:switchDelay];
}

- (void)doChangeInputSource:(NSString *)targetInputId
{
    [[GHInputSourceManager getInstance] selectInputSource:targetInputId];
}


- (void)changeInputSourceForApp:(NSString *)bundleId {
    NSString *targetInputId = [[GHDefaultManager getInstance] getInputId:bundleId withProfile:NULL];
    if (targetInputId != NULL) {
        [self performSelector:@selector(doChangeInputSource:) withObject:targetInputId afterDelay:switchDelay];
    }
}


@end
