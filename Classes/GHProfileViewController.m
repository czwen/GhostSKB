//
//  GHProfileViewController.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileViewController.h"

@interface GHProfileViewController ()

@end

@implementation GHProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //hide header view of tables
    //these two tables have the same delegate and datasource : self
    self.profileList.headerView = NULL;
    self.profileConfigList.headerView = NULL;
}

#pragma mark - table view datasource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"identifiler:%@", tableView.identifier);
    if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        return 1;
    }
    else if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        return 2;
    }
    return 0;
}

//// for view-based tableview
//-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//
//}



@end
