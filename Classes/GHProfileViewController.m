//
//  GHProfileViewController.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileViewController.h"
#import "GHProfileCellView.h"
#import "GHProfileContentCellView.h"
#import "GHDefaultManager.h"
#import "GHDefaultInfo.h"
#import <Carbon/Carbon.h>

@interface GHProfileViewController ()

- (void)sortProfileNames;

@property (strong) NSString *currentProfile;
@property (strong) NSMutableArray *availableInputMethods;
@property (strong) NSMutableDictionary *inputIdInfo;
@end

@implementation GHProfileViewController
@synthesize profilesTableView, profiles, profileConfigs;
@synthesize availableInputMethods;


- (void)sortProfileNames {
    NSArray *arr = [self.profiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = (NSString *)obj1;
        NSString *str2 = (NSString *)obj2;
        return [str1 compare:str2];
    }];
    self.profiles = [NSMutableArray arrayWithArray:arr];
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

- (void)viewWillAppear {
    [super viewWillAppear];
    [self getAlivibleInputMethods];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profiles = [NSMutableArray arrayWithArray:[[GHDefaultManager getInstance] getProfileList]];
    [self sortProfileNames];

    self.currentProfile = [self.profiles objectAtIndex:0];
    self.profileConfigs = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSString *profileName in self.profiles) {
        NSArray *config = [[GHDefaultManager getInstance] getProfileInputConfig:profileName];
        [self.profileConfigs setObject:config forKey:profileName];
    }
    
    self.availableInputMethods = [[NSMutableArray alloc] initWithCapacity:1];
    [self getAlivibleInputMethods];
    // Do view setup here.
    //hide header view of tables
    //these two tables have the same delegate and datasource : self
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger rowCount = 0;
    if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        rowCount = [self.profiles count];
    }
    else if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        NSArray *configs = [self.profileConfigs objectForKey:self.currentProfile];
        rowCount = [configs count];
    }
    
    NSLog(@"numberOfRowsInTableView identifiler:%@ %ld", tableView.identifier, rowCount);
    return rowCount;
}

// for view-based tableview
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    //profile list
    if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        GHProfileCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_IDENTIFIER_PROFILE_CELL owner:self];
        NSString *pname = (NSString *)[self.profiles objectAtIndex:row];
        [view.profileName setStringValue:pname];
        return view;
    }
    else if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        GHProfileContentCellView *view = (GHProfileContentCellView *)[tableView makeViewWithIdentifier:TBL_CELL_IDENTIFIER_PROFILE_CONTENT_CELL owner:self];
        NSArray *defaultConfigs = (NSArray *)[self.profileConfigs objectForKey:self.currentProfile];
        GHDefaultInfo *defaultInfo = [defaultConfigs objectAtIndex:row];
        
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
        if ([view.inputMethodsPopButton.menu numberOfItems] <= 0) {
            for (int i=0; i<[self.availableInputMethods count]; i++) {
                NSDictionary *inputInfo = self.availableInputMethods[i];
                NSString *inputName = [inputInfo objectForKey:@"inputName"];
                NSMenuItem *item = [view.inputMethodsPopButton.menu
                                    addItemWithTitle:inputName
                                    action:NULL
                                    keyEquivalent:@""];
                item.representedObject = view;
            }
        }
        int inputIndex = [[_inputIdInfo objectForKey:defaultInfo.defaultInput] intValue];
        [view.inputMethodsPopButton selectItemAtIndex:inputIndex];
        
        
        return view;
    }
    return NULL;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.profilesTableView.selectedRow;
    NSString *profileName = [self.profiles objectAtIndex:selectedRow];
    self.currentProfile = profileName;
    [self.profileDetailTableView reloadData];
}

- (IBAction)addNewProfile:(id)sender {
    NSLog(@"addNewProfile");
    NSInteger count = [self.profiles count];
    NSString *newProfileName = [NSString stringWithFormat:@"profile%ld", count+1];
    BOOL ok = [[GHDefaultManager getInstance] addProfile:newProfileName];
    if(ok) {
        [self.profiles addObject:newProfileName];
        [self sortProfileNames];
        [self.profilesTableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_PROFILE_LIST_CHANGED object:NULL];
    }
}

- (IBAction)removeProfile:(id)sender {
    NSInteger selectedRow = self.profilesTableView.selectedRow;
    if(selectedRow < 0) {
        //TODO alert
    }
    else {
        NSString *pname = (NSString *)[self.profiles objectAtIndex:selectedRow];
        BOOL ok = [[GHDefaultManager getInstance] removeProfile:pname];
        if (ok) {
            [self.profiles removeObjectAtIndex:selectedRow];
            [self.profilesTableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_PROFILE_LIST_CHANGED object:NULL];
        }
    }
}

@end
