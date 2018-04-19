//
//  GHAdvanceViewController.m
//  GhostSKB
//
//  Created by dmx on 2018/4/19.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import "GHAdvanceViewController.h"
#import "GHAdvanceInputIdCellView.h"
#import "GHAdvanceInputShortcutCellView.h"

#import <Carbon/Carbon.h>

#define TBL_CELL_INPUT_ID @"inputIdCell"
#define TBL_CELL_INPUT_SHORTCUT_ID @"inputShortcutCell"

@interface GHAdvanceViewController ()
@property NSMutableArray *inputMethods;
@end

@implementation GHAdvanceViewController


- (void) getAlivibleInputMethods {
    
    NSMutableString *thisID;
    CFArrayRef availableInputs = TISCreateInputSourceList(NULL, false);
    NSUInteger count = CFArrayGetCount(availableInputs);
    
    for (int i = 0; i < count; i++) {
        TISInputSourceRef inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(availableInputs, i);
        CFStringRef type = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceCategory);
        if (!CFStringCompare(type, kTISCategoryKeyboardInputSource, 0)) {
            thisID = (__bridge NSMutableString *)(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID));
            NSString *canSelectStr = (__bridge NSString *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsSelectCapable);
            Boolean canSelect = [canSelectStr boolValue];
            if (!canSelect) {
                continue;
            }
            
            NSMutableString *inputName = (__bridge NSMutableString *)(TISGetInputSourceProperty(inputSource, kTISPropertyLocalizedName));
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[thisID description],@"id", [inputName description], @"inputName", nil];
            [self.inputMethods addObject:dict];
        }
    }
}

#pragma mark - View methods

- (void)awakeFromNib {
    self.inputSwitchTableView.delegate = self;
    self.inputSwitchTableView.dataSource = self;
    
    self.inputMethods = [[NSMutableArray alloc] initWithCapacity:2];
    [self getAlivibleInputMethods];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - NSTableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.inputMethods count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40.0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
    NSDictionary *info = (NSDictionary *)[self.inputMethods objectAtIndex:row];
    if (columnIndex == 0) {
        GHAdvanceInputIdCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_INPUT_ID owner:self];
        NSString *inputId = [info objectForKey:@"id"];
        [view.inputIdLabel setStringValue:inputId];
        return view;
    }
    else {
        GHAdvanceInputShortcutCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_INPUT_SHORTCUT_ID owner:self];
        view.recorderControl.delegate = self;
        return view;
    }
}

#pragma mark - SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut {
    return YES;
}

//结束录制
- (void)shortcutRecorderDidEndRecording:(SRRecorderControl *)aRecorder {
    NSLog(@"shortcutRecorderDidEndRecording %@", aRecorder.objectValue);
}

- (BOOL)shortcutRecorderShouldBeginRecording:(SRRecorderControl *)aRecorder {
    return TRUE;
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder shouldUnconditionallyAllowModifierFlags:(NSEventModifierFlags)aModifierFlags forKeyCode:(unsigned short)aKeyCode {
    return TRUE;
}



@end
