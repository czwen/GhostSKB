//
//  GHSettingWindowControler.h
//  GhostSKB
//
//  Created by 丁明信 on 7/16/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHSettingWindowControler : NSWindowController
@property (weak) IBOutlet NSPopUpButtonCell *expireSeconds;
@property (weak) IBOutlet NSButton *rememberInputToggle;
@property (weak) IBOutlet NSMenu *secondList;

- (IBAction)onRememberInputToggle:(id)sender;
- (IBAction)gotoGithub:(id)sender;
@end
