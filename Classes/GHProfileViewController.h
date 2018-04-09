//
//  GHProfileViewController.h
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define TBL_IDENTIFIER_PROFILE_LIST @"profileList"
#define TBL_IDENTIFIER_PROFILE_CONFIG_LIST @"profileConfigList"

@interface GHProfileViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *profileList;
@property (weak) IBOutlet NSTableView *profileConfigList;

@end
