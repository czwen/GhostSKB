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

@end

@implementation GHSettingWindowControler

- (NSString *)windowNibName {
    return @"GHSettingWindowControler";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window center];
    
    [self initSecondList];
    [self initRememberCheck];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)initSecondList
{
    [self.secondList removeAllItems];
    for (int i=0; i<=60; i++) {
        NSString *title = [NSString stringWithFormat:@"%ds", i];
        [self.secondList addItemWithTitle:title
                                   action:@selector(onRememberSecondChanges:)
                            keyEquivalent:[NSString stringWithFormat:@"%d", i]];
    }
    
    NSInteger expire_t = [[GHDefaultManager getInstance] rememberAppInputExpireTime];
    NSLog(@"expire_t:::%ld", expire_t);
    [self.secondList performActionForItemAtIndex:expire_t];
}

- (void)initRememberCheck
{
    BOOL isRemember = [[GHDefaultManager getInstance] rememberAppLastInput];
    NSInteger state = isRemember ? 1 : 0;
    self.rememberInputToggle.state = state;
}

- (void)onRememberSecondChanges:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    NSInteger row = [[item keyEquivalent] integerValue];
    [[GHDefaultManager getInstance] setRememberAppInputExpireTime:row];
}

- (IBAction)onRememberInputToggle:(id)sender {
    
    NSInteger state = self.rememberInputToggle.state;
    BOOL rememberInput = state > 0;
    [[GHDefaultManager getInstance] setIsRememberAppLastInput:rememberInput];
}

- (IBAction)gotoGithub:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GH_GITHUB_LINK]];

}
@end
