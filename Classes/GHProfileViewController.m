//
//  GHProfileViewController.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileViewController.h"
#import "GHProfileCellView.h"
#import "GHProfileContentCellView.h"

@interface GHProfileViewController ()

@end

@implementation GHProfileViewController
@synthesize profilesTableView, profiles;

- (void)awakeFromNib {
    self.profilesTableView.dataSource = self;
    self.profilesTableView.delegate = self;
    
    self.profiles = [NSArray arrayWithObjects:@"dmx", @"default", nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //hide header view of tables
    //these two tables have the same delegate and datasource : self
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger rowCount = 0;
    if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        rowCount = [self.profiles count];
    }
    else if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        rowCount = 3;
    }
    
    NSLog(@"numberOfRowsInTableView identifiler:%@ %ld", tableView.identifier, rowCount);
    return rowCount;
}

// for view-based tableview
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    //profile list
    if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        GHProfileCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_IDENTIFIER_PROFILE_CELL owner:self];
        NSString *pname = (NSString *)[self.profiles objectAtIndex:row];
        [view.profileName setStringValue:pname];
        return view;
    }
    else if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        GHProfileContentCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_IDENTIFIER_PROFILE_CONTENT_CELL owner:self];
        return view;
    }
    return NULL;
}

@end
