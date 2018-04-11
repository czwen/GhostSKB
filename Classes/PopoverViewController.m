//
//  PopoverViewController.m
//  GhostSKB
//
//  Created by 丁明信 on 16/4/6.
//  Copyright © 2016年 丁明信. All rights reserved.
//

#import "PopoverViewController.h"
#import "GHInputDefaultCellView.h"
#import "GHInputAddDefaultCellView.h"
#import "GHDefaultManager.h"
#import "GHSettingWindowControler.h"
#import "GHDefaultInfo.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface PopoverViewController ()

- (BOOL)isAppDuplicated: (NSString *)bundleId;

@end

@implementation PopoverViewController

@synthesize appPopOver;
@synthesize defaultKeyBoards;
@synthesize availableInputMethods;

//This method will be invoked after viewDidLoad every time when view show up
- (void)viewWillAppear {
    [super viewWillAppear];
    [self getAlivibleInputMethods];
}

// This method only be invoked once
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.availableInputMethods = [[NSMutableArray alloc] initWithCapacity:1];
    [self getAlivibleInputMethods];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.headerView = NULL;
//    self.defaultKeyBoards = [[GHDefaultManager getInstance] getDefaultKeyBoards];
    
    //init app popover
    self.appPopOver = [[NSPopover alloc] init];
    self.appPopOver.behavior = NSPopoverBehaviorTransient;
    [self toggleDarkMode];
}

- (void) getAlivibleInputMethods {
    [self.availableInputMethods removeAllObjects];
    
    NSMutableString *thisID;
    CFArrayRef availableInputs = TISCreateInputSourceList(NULL, false);
    NSUInteger count = CFArrayGetCount(availableInputs);
    if (_inputIdInfo == NULL) {
        _inputIdInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    int inputMethodCount = 0;
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
            
            [self.availableInputMethods addObject:dict];
            [_inputIdInfo setObject:[NSString stringWithFormat:@"%d", inputMethodCount] forKey:[thisID description]];
            inputMethodCount++;
        }
    }
}

- (void)toggleDarkMode {
    if ([AppDelegate isSystemCurrentDarkMode]) {
        self.appPopOver.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        [_tableView setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    }
    else {
        self.appPopOver.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        [_tableView setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    }
}
#pragma mark - table view datasource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger num = [self.defaultKeyBoards count] + 1;
    return num;
}

// for view-based tableview
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (row < [self.defaultKeyBoards count]) {
        GHInputAddDefaultCellView *view = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        GHDefaultInfo *defaultInfo = [self.defaultKeyBoards objectAtIndex:row];
        
        if (defaultInfo.defaultInput == NULL) {
            NSString *defaultInputId = (NSString *)[[self.availableInputMethods objectAtIndex:0] objectForKey:@"id"];
            defaultInfo.defaultInput = defaultInputId;
        }
        
        
        if (defaultInfo.appUrl != NULL && defaultInfo.appBundleId != NULL){
            NSURL *appUrl = [NSURL fileURLWithPath:defaultInfo.appUrl];
            NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[appUrl path]];
            NSBundle *appBundle =[NSBundle bundleWithPath:[appUrl path]];
            NSString *appName = [[NSFileManager defaultManager] displayNameAtPath: [appBundle bundlePath]];
            //防止app被删除导致的错误
            if (appName != NULL) {
                view.appName.stringValue = appName;
                view.appButton.image = icon;
            }
        }
        else {
            view.appButton.image = NULL;
            view.appName.stringValue = @"";
        }

        
        view.row = row;
        if ([view.menu numberOfItems] <= 0) {
            for (int i=0; i<[self.availableInputMethods count]; i++) {
                NSDictionary *inputInfo = self.availableInputMethods[i];
                NSString *inputName = [inputInfo objectForKey:@"inputName"];
                NSMenuItem *item = [view.menu
                                    addItemWithTitle:inputName
                                    action:@selector(onInputSourceChange:)
                                    keyEquivalent:[[inputInfo objectForKey:@"id"] description]];
                item.representedObject = view;
            }
        }
        int inputIndex = [[_inputIdInfo objectForKey:defaultInfo.defaultInput] intValue];
        [view.inputMethodsPopButon selectItemAtIndex:inputIndex];
        
        return view;
        
    }
    else {
        GHInputDefaultCellView *view = [tableView makeViewWithIdentifier:@"BottomCell" owner:self];
        
        return view;
    }

}


#pragma mark - table view delegate

#pragma mark - table view noditfication
-(void)tableViewSelectionDidChange:(NSNotification *)notification {
//    NSLog(@"%d",[[notification object] selectedRow]);
}

#pragma mark - IBoutlets Actions

- (IBAction)onAddDefault:(id)sender {
    BOOL hasEmptyEntry = [self checkEmptyEntryInList];
    if (hasEmptyEntry) {
        NSLog(@"有空列表项");
        return;
    }
    
    GHDefaultInfo *info = [[GHDefaultInfo alloc] init];
    [self.defaultKeyBoards addObject:info];
    [self.tableView reloadData];
}

- (IBAction)onRemoveDefault:(id)sender {
    NSInteger row = [_tableView rowForView:(NSView *)sender];
    GHDefaultInfo *info = [self.defaultKeyBoards objectAtIndex:row];
    
    [[GHDefaultManager getInstance] removeAppInputDefault:info.appBundleId];
    [self.defaultKeyBoards removeObjectAtIndex:row];
    [self.tableView reloadData];
}

- (IBAction)onAppButtonClick:(id)sender {
    
    NSButton *button = (NSButton *)sender;
    GHInputAddDefaultCellView *cellView = (GHInputAddDefaultCellView *)[button superview];
    _currentSelectRow = cellView.row;
    _currentSelectedCell = cellView;
    [self showOpenPanel];
}


- (IBAction)onInputSourcePopButtonClick:(id)sender {
}

#pragma mark - Other util functions

- (BOOL)checkEmptyEntryInList{
    for (GHDefaultInfo *info in self.defaultKeyBoards) {
        if (info.appBundleId == NULL) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void)showAppListController:(id)sender {
    if ([self.appPopOver isShown]) {
        [self.appPopOver performClose:nil];
    }
    else {
        NSButton *button = (NSButton *)sender;
        [self.appPopOver showRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMinX];
    }
}

- (void)showOpenPanel {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSArray *appDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES);
    NSString *appDir = [appDirs objectAtIndex:0];
    [panel setDirectoryURL:[NSURL URLWithString:appDir]];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            
            
            NSBundle *selectedAppBundle =[NSBundle bundleWithURL:url];
            NSString *bundleIdentifier = [selectedAppBundle bundleIdentifier];
            if([self isAppDuplicated:bundleIdentifier]) {
//                NSRunAlertPanel(NSLocalizedString(@"duplicated_app", @""), NSLocalizedString(@"already_have_same_app", @""), @"OK", nil, nil);
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:NSLocalizedString(@"duplicated_app", @"")];
                [alert setInformativeText:NSLocalizedString(@"already_have_same_app", @"")];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
                
                break;
            }
            NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[url path]];
            _currentSelectedCell.appButton.image = icon;
            
            NSString *appName = [[NSFileManager defaultManager] displayNameAtPath: [selectedAppBundle bundlePath]];
            _currentSelectedCell.appName.stringValue = appName;
            
            NSString *selectedInputId = [[_currentSelectedCell.inputMethodsPopButon selectedItem] keyEquivalent];
            
            GHDefaultInfo *info = [self.defaultKeyBoards objectAtIndex:_currentSelectRow];
            info.appUrl = [url path];
            info.appBundleId = bundleIdentifier;
            info.defaultInput = selectedInputId;
            [info saveToDefaultStorage];
            
            [self.defaultKeyBoards sortUsingComparator:^NSComparisonResult(id  _Nonnull a, id  _Nonnull b) {
                GHDefaultInfo *aInfo = (GHDefaultInfo *)a;
                GHDefaultInfo *bInfo = (GHDefaultInfo *)b;
                return [aInfo.appBundleId compare:bInfo.appBundleId];
            }];
            [self.tableView reloadData];

            // post application
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:url, @"appUrl", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GH_APP_SELECTED" object:NULL userInfo:userInfo];
            
            break;
        }
    }
}

-(void)onInputSourceChange:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    GHInputAddDefaultCellView *cellView = (GHInputAddDefaultCellView *)item.representedObject;
    NSInteger row = cellView.row;
    
    GHDefaultInfo *info = [self.defaultKeyBoards objectAtIndex:row];
    info.defaultInput = [item keyEquivalent];
    [info saveToDefaultStorage];
    
}

- (IBAction)terminateSelf:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)onSettingPressed:(id)sender {
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    [delegate showSettingWindow];
}

- (BOOL) isAppDuplicated: (NSString *)bundleId{
    for(id defaultInfo in self.defaultKeyBoards) {
        GHDefaultInfo *info = (GHDefaultInfo *)defaultInfo;
        if(bundleId!= NULL && bundleId.length > 0 && [bundleId isEqualToString:info.appBundleId]) {
            return true;
        }
    }
    return false;
}

@end
