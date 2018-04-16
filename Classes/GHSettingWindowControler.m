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

@interface GHSettingWindowControler ()
@property NSMutableDictionary *toolBarItems;
@property NSMutableArray *toolbarIdentifiers;
- (void)toolbarItemSelected:(id)sender;
@end

@implementation GHSettingWindowControler
@synthesize toolBarItems, toolbarIdentifiers;

- (void)awakeFromNib {
    
    NSMutableDictionary *items = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSArray *identifiers = @[@"General", @"Sync", @"About"];
    
    NSInteger tag = 0;
    for (NSString *identifier in identifiers) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:identifier];
        [item setImage:[NSImage imageNamed:[NSString stringWithFormat:@"ToolBarIcon%@", identifier]]];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemSelected:)];
        [item setTag:tag];
        [items setObject:item forKey:identifier];
        tag += 1;
    }

    self.toolBarItems = items;
    self.toolbarIdentifiers = [NSMutableArray arrayWithArray:identifiers];
    [self.toolbarIdentifiers insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
    [self.toolbarIdentifiers insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:[self.toolbarIdentifiers count]];
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"GhoskSKBPreferenceWindowToolbar"];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];
    [toolbar setSelectedItemIdentifier:[self.toolbarIdentifiers objectAtIndex:1]];
    [self.window setToolbar:toolbar];

}

- (void)toolbarItemSelected:(id)sender {
    
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
