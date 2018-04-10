//
//  GHProfileViewController.h
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TBL_IDENTIFIER_PROFILE_LIST @"profileList"
#define TBL_IDENTIFIER_PROFILE_CONFIG_LIST @"profileDetailTable"

#define TBL_CELL_IDENTIFIER_PROFILE_CELL @"profileCell"
#define TBL_CELL_IDENTIFIER_PROFILE_CONTENT_CELL @"profileItemCell"

@interface GHProfileViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *profilesTableView;
@property (weak) IBOutlet NSTableView *profileDetailTableView;

@property (strong) NSArray *profiles;

@end
