//
//  GHSyncViewController.m
//  GhostSKB
//
//  Created by dmx on 16/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHSyncViewController.h"
#import <CloudKit/CloudKit.h>

@interface GHSyncViewController ()

@end

@implementation GHSyncViewController

- (void)awakeFromNib {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 20)];
    return tf;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 3;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"tableViewSelectionDidChange");
}

@end
