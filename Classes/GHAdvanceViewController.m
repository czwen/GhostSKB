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
#import "GHInputSourceManager.h"
#import "Constant.h"

#import <Carbon/Carbon.h>
#import <PTHotKey/PTHotKey.h>
#import <PTHotKey/PTKeyCombo.h>
#import <pthotkey/PTHotKeyCenter.h>

#import "MBProgressHUD.h"

#define TBL_CELL_INPUT_ID @"inputIdCell"
#define TBL_CELL_INPUT_SHORTCUT_ID @"inputShortcutCell"
#define DELAY_SLIDER_MIN 0.016
#define DELAY_SLIDER_MAX 0.02
#define DELAY_SLIDER_STEP 0.0002

@interface GHAdvanceViewController ()

@property (nonatomic, strong)NSMutableArray *inputMethods;
@property (assign, nonatomic) BOOL initialized;
@property (assign, nonatomic) float delayTime;
@property (nonatomic, strong)NSMutableDictionary *shortcut;

@end

@implementation GHAdvanceViewController

@synthesize shortcut;


- (void) getAlivibleInputMethods {    
    self.inputMethods = [GHDefaultManager getAlivibleInputMethods];
}

- (void)initDelaySlider {
    self.delayTimeSlider.maxValue = DELAY_SLIDER_MAX;
    self.delayTimeSlider.minValue = DELAY_SLIDER_MIN;
    self.delayTimeSlider.numberOfTickMarks = (DELAY_SLIDER_MAX - DELAY_SLIDER_MIN)/DELAY_SLIDER_STEP+1;
    self.delayTime = [[GHDefaultManager getInstance] getDelayTime];
    [self.delayTimeSlider bind:NSValueBinding toObject:self withKeyPath:@"delayTime" options:NULL];
    [self.delayTimeLabel bind:NSValueBinding toObject:self withKeyPath:@"delayTime" options:NULL];
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
            [self.profiles sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *str1 = (NSString *)obj1;
                NSString *str2 = (NSString *)obj2;
                return [str1 compare:str2];
            }];

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
    NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
    [ncenter addObserver:self selector:@selector(inputSourceListChanged:) name:GH_NK_INPUT_SOURCE_LIST_CHANGED object:NULL];
    
    [self.labelSelectProfile setStringValue:NSLocalizedString(@"select_profile_to_setup_hotkey", @"")];
    [self.labelAutoSwitchDelay setStringValue:NSLocalizedString(@"auto_switch_delay", @"")];
    
    NSArray *titleStrIds = @[@"table_header_title_input", @"table_header_title_shortcut"];
    for (int i=0; i< [self.inputSwitchTableView.tableColumns count]; i++) {
        NSTableColumn *column = [self.inputSwitchTableView.tableColumns objectAtIndex:i];
        NSString *strId = [titleStrIds objectAtIndex:i];
        column.headerCell.title = NSLocalizedString(strId, @"");
    }
    [self.hotkeyEnableButton setTitle:NSLocalizedString(@"enable_hotkey", @"")];
    [self initDelaySlider];
    
    
}

#pragma mark - Notifications

- (void)inputSourceListChanged:(NSNotification *)notification {
    [self getAlivibleInputMethods];
    [self.inputSwitchTableView reloadData];
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
        NSString *inputId = [dkey stringByReplacingOccurrencesOfString:@"_" withString:@"."];
        if (![[GHInputSourceManager getInstance] hasInputSourceEnabled:inputId]) {
            continue;
        }
        NSDictionary *info = [self.shortcut objectForKey:dkey];
        NSInteger aKeyCode = [[info objectForKey:@"keyCode"] integerValue];
        NSUInteger aModifiers = SRCocoaToCarbonFlags([[info objectForKey:@"modifierFlags"] unsignedIntegerValue]);
        PTKeyCombo *aComb = [PTKeyCombo keyComboWithKeyCode: aKeyCode
                                                  modifiers: aModifiers];
        
        if ([newComb isEqual:aComb]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"indicator_duplicated_hotkey", @"");
            [hud hide:YES afterDelay:0.5];
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

- (IBAction)delayTimeChanged:(id)sender {
    NSSlider *slider = (NSSlider *)sender;
    int num = round(([slider floatValue] - DELAY_SLIDER_MIN)/DELAY_SLIDER_STEP);
    double doubleValue = slider.minValue + num*DELAY_SLIDER_STEP;
    self.delayTime = doubleValue;
    
    [[GHDefaultManager getInstance] updateDelayTime:doubleValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_DELAY_TIME_CHANGED object:NULL];
}



@end
