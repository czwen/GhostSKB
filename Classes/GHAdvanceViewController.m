//
//  GHAdvanceViewController.m
//  GhostSKB
//
//  Created by dmx on 2018/4/19.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import "GHAdvanceViewController.h"

@interface GHAdvanceViewController ()

@end

@implementation GHAdvanceViewController


- (void)awakeFromNib {
    self.inputSwitchTableView.delegate = self;
    self.inputSwitchTableView.dataSource = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


#pragma mark - nstableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 1;
}
@end
