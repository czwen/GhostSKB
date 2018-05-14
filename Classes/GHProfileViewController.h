//
//  GHProfileViewController.h
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHProfileViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *profilesTableView;
@property (weak) IBOutlet NSTableView *profileDetailTableView;
@property (weak) IBOutlet NSButton *addDefaultInputConfig;
@property (weak) IBOutlet NSButton *removeInputConfig;
@property (weak) IBOutlet NSButton *btnDeleteProfile;

@property (strong) NSMutableArray *profiles;
@property (strong) NSMutableDictionary *profileConfigs;

- (IBAction)addNewProfile:(id)sender;
- (IBAction)removeProfile:(id)sender;
- (IBAction)removeAppInput:(id)sender;
- (IBAction)addAppInput:(id)sender;

@end
