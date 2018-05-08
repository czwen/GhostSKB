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

@end

@implementation GHInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSInteger year = [comp year];
    NSString *copyStr = [NSString stringWithFormat:@"2016-%zd @ dingmingxin all rights reserved", year];
    [self.copyrightLabel setStringValue:copyStr];
}

- (IBAction)imageClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.github.com/dingmingxin/GhostSKB"]];
}
@end
