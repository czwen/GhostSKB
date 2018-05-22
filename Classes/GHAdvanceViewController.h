//
//  GHAdvanceViewController.h
//  GhostSKB
//
//  Created by dmx on 2018/4/19.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface GHAdvanceViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, SRRecorderControlDelegate, NSOpenSavePanelDelegate>
@property (weak) IBOutlet NSPopUpButton *profileSelector;
@property (weak) IBOutlet NSTableView *inputSwitchTableView;
@property (nonatomic, strong)NSString *profile;
@property (nonatomic, strong)NSMutableArray *profiles;
@property (weak) IBOutlet NSSlider *delayTimeSlider;
@property (weak) IBOutlet NSTextField *delayTimeLabel;
@property (weak) IBOutlet NSButton *hotkeyEnableButton;
- (IBAction)delayTimeChanged:(id)sender;
@property (weak) IBOutlet NSTextField *labelAutoSwitchDelay;
@property (weak) IBOutlet NSTextField *labelSelectProfile;

@end
