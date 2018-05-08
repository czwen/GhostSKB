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
- (IBAction)downloadFromICloud:(id)sender;
- (IBAction)uploadToICloud:(id)sender;

@end

@implementation GHSyncViewController

- (void)awakeFromNib {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
}

- (IBAction)downloadFromICloud:(id)sender {
    NSLog(@"download config");
}

- (IBAction)uploadToICloud:(id)sender {
    NSLog(@"upload config");
}
@end
