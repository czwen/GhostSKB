//
//  GHSettingTabViewController.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHSettingTabViewController.h"
#import "GHProfileViewController.h"
@interface GHSettingTabViewController ()

@end

@implementation GHSettingTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSArray *tabControllers = [NSArray arrayWithObjects:@"ProfileViewController", @"InfoViewController", nil];
    NSStoryboard *board = [NSStoryboard storyboardWithName:@"Storyboard" bundle:nil];

    NSArray *items = self.tabView.tabViewItems;
    for (int i=0; i< [items count]; i++) {
        NSTabViewItem *item = [items objectAtIndex:i];
        NSString *identifier = [tabControllers objectAtIndex:i];
        NSViewController *controller = [board instantiateControllerWithIdentifier:identifier];
        [item setView:controller.view];
    }
}

@end
