//
//  GHSyncViewController.h
//  GhostSKB
//
//  Created by dmx on 16/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHSyncViewController : NSViewController

- (IBAction)downloadFromICloud:(id)sender;
- (IBAction)uploadToICloud:(id)sender;
- (IBAction)tryOpeniCloudPrefPane:(id)sender;
@property (weak) IBOutlet NSButton *loginButton;

@end
