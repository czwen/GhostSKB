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


    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)gotoGithub:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GH_GITHUB_LINK]];

}
@end
