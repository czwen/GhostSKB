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
#import "GHKeybindingManager.h"
#import "Constant.h"

#import <Carbon/Carbon.h>
#import <PTHotKey/PTHotKey.h>
#import <PTHotKey/PTKeyCombo.h>
#import <pthotkey/PTHotKeyCenter.h>

#define TBL_CELL_INPUT_ID @"inputIdCell"
#define TBL_CELL_INPUT_SHORTCUT_ID @"inputShortcutCell"

@interface GHAdvanceViewController ()

@property (nonatomic, strong)NSMutableArray *inputMethods;
@property (assign) BOOL initialized;

@property (nonatomic, strong)NSMutableDictionary *shortcut;

@end

@implementation GHAdvanceViewController

@synthesize shortcut;


- (void) getAlivibleInputMethods {    
    self.inputMethods = [GHDefaultManager getAlivibleInputMethods];
}

#pragma mark - View methods

- (void)awakeFromNib {
    //保证执行一次
    @synchronized(self) {
        if (!self.initialized) {
            self.initialized = TRUE;
            
            self.inputMethods = [[NSMutableArray alloc] initWithCapacity:2];
            [self getAlivibleInputMethods];

            GHDefaultManager *manager = [GHDefaultManager getInstance];

            self.profile = [manager getDefaultProfileName];
            self.profiles = [[manager getProfileList] mutableCopy];

            self.shortcut = [[manager getKeyBindings:self.profile] mutableCopy];

            //kvo
            for (NSDictionary *info in self.inputMethods) {
                NSString *inputId = [info objectForKey:@"id"];
                NSString *inputIdRep = [inputId stringByReplacingOccurrencesOfString:@"." withString:@"_"];
                NSString *keyPath = [NSString stringWithFormat:@"%@.%@",KVO_K_SHORTCUT,inputIdRep];
                [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
            }

            [self addObserver:self forKeyPath:KVO_K_PROFILE options:NSKeyValueObservingOptionNew context:NULL];
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
        [view.inputIdLabel setStringValue:[info objectForKey:@"inputName"]];
        return view;
    }
    else {
        GHAdvanceInputShortcutCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_INPUT_SHORTCUT_ID owner:tableView];
        view.recorderControl.delegate = self;
        NSString *inputIdRep = [inputId stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        NSString *keyPath = [NSString stringWithFormat:@"%@.%@", KVO_K_SHORTCUT, inputIdRep];
        [view.recorderControl bind:NSValueBinding toObject:self withKeyPath:keyPath options:nil];
        return view;
    }
}

#pragma mark - SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut {
    NSInteger keyCode = [[aShortcut objectForKey:@"keyCode"] integerValue];
    NSUInteger modifiers = SRCocoaToCarbonFlags([[aShortcut objectForKey:@"modifierFlags"] unsignedIntegerValue]);
    PTKeyCombo *newComb = [PTKeyCombo keyComboWithKeyCode:keyCode modifiers:modifiers];
    
    for (NSString *dkey in self.shortcut) {
        NSDictionary *info = [self.shortcut objectForKey:dkey];
        NSInteger aKeyCode = [[info objectForKey:@"keyCode"] integerValue];
        NSUInteger aModifiers = SRCocoaToCarbonFlags([[info objectForKey:@"modifierFlags"] unsignedIntegerValue]);
        PTKeyCombo *aComb = [PTKeyCombo keyComboWithKeyCode: aKeyCode
                                                  modifiers: aModifiers];
        
        if ([newComb isEqual:aComb]) {
            //TODO 提示duplicated keycode
            return NO;
        }
    }
    return YES;
}

//结束录制
- (void)shortcutRecorderDidEndRecording:(SRRecorderControl *)aRecorder {
    [[PTHotKeyCenter sharedCenter] resume];
}

- (BOOL)shortcutRecorderShouldBeginRecording:(SRRecorderControl *)aRecorder {
    [[PTHotKeyCenter sharedCenter] pause];
    return TRUE;
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder shouldUnconditionallyAllowModifierFlags:(NSEventModifierFlags)aModifierFlags forKeyCode:(unsigned short)aKeyCode {
    return YES;
}

#pragma mark - kvo observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    GHDefaultManager *manager = [GHDefaultManager getInstance];
    if ([keyPath containsString:KVO_K_SHORTCUT]) {
        [manager updateKeyBindings:self.shortcut for:self.profile];
        if ([self.profile isEqualToString:[manager getDefaultProfileName]]) {
            [[GHKeybindingManager getInstance] setProfileHotKeys:self.profile];
        }
    }
    else if ([keyPath isEqualToString:KVO_K_PROFILE]) {
        self.shortcut = [[manager getKeyBindings:self.profile] mutableCopy];
        [self.inputSwitchTableView reloadData];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
