//
//  GHAdvanceViewController.h
//  GhostSKB
//
//  Created by dmx on 2018/4/19.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHAdvanceViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *inputSwitchTableView;
@end
