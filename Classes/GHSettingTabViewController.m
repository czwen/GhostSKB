//
//  GHSettingTabViewController.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHSettingTabViewController.h"

@interface GHSettingTabViewController ()

@end

@implementation GHSettingTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    CGSize originSize = self.view.bounds.size;
    CGPoint origin = self.view.bounds.origin;
    self.view.bounds = NSMakeRect(origin.x, origin.y+30, originSize.width, originSize.height);
}

@end
