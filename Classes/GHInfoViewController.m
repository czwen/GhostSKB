//
//  GHInfoViewController.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHInfoViewController.h"

@interface GHInfoViewController ()
@property (weak) IBOutlet NSTextField *copyrightLabel;
- (IBAction)imageClicked:(id)sender;
@property (weak) IBOutlet NSTextField *versionLabel;


@end

@implementation GHInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSInteger year = [comp year];
    NSString *copyStr = [NSString stringWithFormat:@"© 2016-%zd DingMingxin All Rights Reserved", year];
    [self.copyrightLabel setStringValue:copyStr];
    
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"version", @""), version]];
}

- (IBAction)imageClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.github.com/dingmingxin/GhostSKB"]];
}
@end
