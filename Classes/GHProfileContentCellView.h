//
//  GHProfileContentCellView.h
//  GhostSKB
//
//  Created by dmx on 10/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GHDefaultInfo.h"

@interface GHProfileContentCellView : NSTableCellView
@property(nonatomic, assign) NSInteger row;

@property (retain) IBOutlet NSButton *appButton;
@property (retain) IBOutlet NSTextField *appName;
@property (retain) IBOutlet NSPopUpButton *inputMethodsPopButton;


- (void)initContent:(NSArray *)inputMethodsInfoArray with:(GHDefaultInfo *)defaultInfo;
@end
