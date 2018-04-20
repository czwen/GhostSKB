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
#import "GHDefaultManager.h"

#import <Carbon/Carbon.h>

#define TBL_CELL_INPUT_ID @"inputIdCell"
#define TBL_CELL_INPUT_SHORTCUT_ID @"inputShortcutCell"

@interface GHAdvanceViewController ()

@property NSMutableArray *inputMethods;
@property NSString *defaultProfile;
@property (assign) BOOL initialized;

@property (nonatomic, strong)NSMutableDictionary *shortcut;

@end

@implementation GHAdvanceViewController

@synthesize shortcut;


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
    //保证执行一次
    @synchronized(self) {
        if (!self.initialized) {
            NSLog(@"awkeFromNib");
            self.initialized = TRUE;
            
            self.inputMethods = [[NSMutableArray alloc] initWithCapacity:2];
            [self getAlivibleInputMethods];
            
            self.defaultProfile = [[GHDefaultManager getInstance] getDefaultProfileName];
            
            self.shortcut = [[NSMutableDictionary alloc] initWithCapacity:2];
            
            for (NSDictionary *info in self.inputMethods) {
                NSString *inputId = [info objectForKey:@"id"];
                NSString *inputIdRep = [inputId stringByReplacingOccurrencesOfString:@"." withString:@"_"];
                NSString *keyPath = [NSString stringWithFormat:@"shortcut.%@", inputIdRep];
                [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
            }
        }
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
}

- (void)viewDidAppear {
    [super viewDidAppear];
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
    NSString *inputId = [info objectForKey:@"id"];
    if (columnIndex == 0) {
        GHAdvanceInputIdCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_INPUT_ID owner:tableView];
        [view.inputIdLabel setStringValue:inputId];
        return view;
    }
    else {
        GHAdvanceInputShortcutCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_INPUT_SHORTCUT_ID owner:tableView];
        view.recorderControl.delegate = self;
        NSString *inputIdRep = [inputId stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        NSString *keyPath = [NSString stringWithFormat:@"%@.%@", @"shortcut", inputIdRep];
        [view.recorderControl bind:NSValueBinding toObject:self withKeyPath:keyPath options:nil];
        return view;
    }
}

#pragma mark - SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut {
    return YES;
}

//结束录制
- (void)shortcutRecorderDidEndRecording:(SRRecorderControl *)aRecorder {
//    NSLog(@"shortcutRecorderDidEndRecording %@", aRecorder.objectValue);
}

- (BOOL)shortcutRecorderShouldBeginRecording:(SRRecorderControl *)aRecorder {
    return TRUE;
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder shouldUnconditionallyAllowModifierFlags:(NSEventModifierFlags)aModifierFlags forKeyCode:(unsigned short)aKeyCode {
    return TRUE;
}

#pragma mark - kvo observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath containsString:@"shortcut."]) {
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
