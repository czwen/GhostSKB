//
//  GHSettingWindowControler.m
//  GhostSKB
//
//  Created by 丁明信 on 7/16/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import "GHSettingWindowControler.h"
#import "GHDefaultManager.h"
#import "Constant.h"
#import "GHProfileViewController.h"

#define ID_PROFILES @"profile"
#define ID_SYNC @"sync"
#define ID_ADVANCE @"advance"
#define ID_ABOUT @"about"
#define ID_INSTALL @"install"

@interface GHSettingWindowControler ()

@property NSMutableDictionary *toolBarItems;
@property NSMutableArray *toolbarIdentifiers;
@property NSMutableDictionary *controllers;
@property NSDictionary *controllerIdMap;
@property (nonatomic) NSString *selectedIdentifier;

- (void)toolbarItemSelected:(id)sender;
- (void)initToolbar;
- (void)showView:(NSString *)identifier;
-(NSRect) frameRectWithPin:(NSPoint)point andContentSize:(NSSize)size;

@end

@implementation GHSettingWindowControler
@synthesize toolBarItems, toolbarIdentifiers;

- (void)initToolbar {
    NSMutableDictionary *items = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSArray *identifiers = @[ID_PROFILES, ID_ADVANCE, ID_INSTALL, ID_SYNC, ID_ABOUT];
    NSArray *icons = @[
                       [NSString stringWithFormat:@"toolbaricon_%@", ID_PROFILES],
                       NSImageNameAdvanced,
                       NSImageNameAdvanced,
                       [NSString stringWithFormat:@"toolbaricon_%@", ID_SYNC],
                       NSImageNameInfo,
                       ];
    NSInteger tag = 0;
    for (int i=0; i< [identifiers count]; i++) {
        NSString *identifier = [identifiers objectAtIndex:i];
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        NSString *key = [NSString stringWithFormat:@"tab_%@_title", identifier];
        [item setLabel:NSLocalizedString(key, @"")];
        [item setImage:[NSImage imageNamed:[icons objectAtIndex:i]]];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemSelected:)];
        [item setTag:tag];
        [items setObject:item forKey:identifier];
        tag += 1;
    }
    
    self.toolBarItems = items;
    
    //identifiers
    self.toolbarIdentifiers = [identifiers mutableCopy];
    [self.toolbarIdentifiers insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
    [self.toolbarIdentifiers insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:[self.toolbarIdentifiers count]];
    
    //init toolbar
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"GhoskSKBPreferenceWindowToolbar"];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];
    [toolbar setSelectedItemIdentifier:[self.toolbarIdentifiers objectAtIndex:1]];
    [self.window setToolbar:toolbar];
    self.selectedIdentifier = [self.toolbarIdentifiers objectAtIndex:1];
    //initial viewcontroller
    [self showView:ID_PROFILES];
}

- (void)awakeFromNib {
    self.controllerIdMap = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"ProfileViewController", ID_PROFILES,
                            @"InfoViewController", ID_ABOUT,
                            @"InstallViewController", ID_INSTALL,
                            @"SyncViewController", ID_SYNC,
                            @"AdvanceViewController", ID_ADVANCE,
                            nil];
    [self initToolbar];
}

- (void)toolbarItemSelected:(id)sender {
    NSToolbarItem* item = sender;
    NSString *identifier = item.itemIdentifier;
    if ([self.selectedIdentifier isEqualToString:identifier]) {
        return;
    }
    self.selectedIdentifier = identifier;
    [self showView:identifier];
}

- (void)showView:(NSString *)identifier {
    NSViewController *controller = [self.controllers objectForKey:identifier];
    if (controller == NULL) {
        NSStoryboard *board = [NSStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        NSString *storyboarId = [self.controllerIdMap objectForKey:identifier];
        controller = [board instantiateControllerWithIdentifier:storyboarId];
    }

    NSView *newView = controller.view;
    NSSize newSize = [newView frame].size;
    NSRect newFrame = [self frameRectWithPin:NSZeroPoint andContentSize:newSize];
    
    [newView setFrameOrigin:NSZeroPoint];
    [newView setAutoresizingMask:NSViewMaxYMargin | NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin];

    NSString *key = [NSString stringWithFormat:@"tab_%@_title", identifier];
    [self.window setTitle:NSLocalizedString(key, @"")];
    [self.window setContentView:newView];
    self.window.contentViewController = controller;
    [self.window setFrame:newFrame display:YES animate:YES];
    //不允许用户手动缩放窗口大小
    self.window.styleMask &= ~NSWindowStyleMaskResizable;
    [self.controllers setObject:controller forKey:identifier];
}


- (NSRect)frameRectWithPin:(NSPoint)point andContentSize:(NSSize)size
{
    NSRect oldFrame = [self.window frame];
    NSRect newFrame = [self.window frameRectForContentRect:NSMakeRect(0,0,size.width,size.height)];
    newFrame.origin.x = (oldFrame.origin.x + oldFrame.size.width / 2.0) - newFrame.size.width / 2.0;
    newFrame.origin.y = (oldFrame.origin.y + oldFrame.size.height) - newFrame.size.height;
    return newFrame;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window center];
    [NSApp activateIgnoringOtherApps:YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - NSToolBarDelegate
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [self.toolBarItems objectForKey:itemIdentifier];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarIdentifiers;
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarIdentifiers;
}
- (NSArray<NSToolbarItemIdentifier> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarIdentifiers;
}

@end
