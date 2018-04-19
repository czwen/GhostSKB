//
//  GHAdvanceViewController.h
//  GhostSKB
//
//  Created by dmx on 2018/4/19.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface GHAdvanceViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, SRRecorderControlDelegate>

@property (weak) IBOutlet NSTableView *inputSwitchTableView;
@end
