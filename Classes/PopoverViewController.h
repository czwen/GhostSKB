//
//  PopoverViewController.h
//  GhostSKB
//
//  Created by 丁明信 on 16/4/6.
//  Copyright © 2016年 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "GHInputAddDefaultCellView.h"

@interface PopoverViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate> {
    @private
    NSInteger _currentSelectRow;
    GHInputAddDefaultCellView *_currentSelectedCell;
    NSMutableDictionary *_inputIdInfo;
}
@property (nonatomic,strong) NSMutableArray *defaultKeyBoards;
@property (nonatomic,strong) NSMutableArray *availableInputMethods;
@property (nonatomic,strong) NSPopover *appPopOver;

- (void)toggleDarkMode;

- (IBAction)terminateSelf:(id)sender;
- (IBAction)onSettingPressed:(id)sender;
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet NSButton *quitButton;

@property (assign) IBOutlet NSTableView *tableView;

- (IBAction)onAddDefault:(id)sender;
- (IBAction)onRemoveDefault:(id)sender;
- (IBAction)onAppButtonClick:(id)sender;
- (IBAction)onInputSourcePopButtonClick:(id)sender;
@end
