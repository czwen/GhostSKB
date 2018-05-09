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
#import "MBProgressHUD.h"
#import <Carbon/Carbon.h>

#define TBL_IDENTIFIER_PROFILE_LIST @"profileList"
#define TBL_IDENTIFIER_PROFILE_CONFIG_LIST @"profileDetailTable"

#define TBL_CELL_IDENTIFIER_PROFILE_CELL @"profileCell"
#define TBL_CELL_IDENTIFIER_PROFILE_CONTENT_CELL @"profileItemCell"


@interface GHProfileViewController ()

- (void)sortProfileNames;
- (void)duplicatedProfile;
- (void)tryAddNewProfile;

- (void)updateProfileList;
- (void)updateProfileConfigDicts;
- (BOOL)profileContainAppInput:(NSString *)bundleId;

- (void)showAppSelectPanel:(BOOL)newInput;

@property (strong, nonatomic) NSString *currentProfile;
@property (strong, nonatomic) NSMutableArray *availableInputMethods;
@property (assign, nonatomic) BOOL removeAppInputBtnEnabled;
@end

@implementation GHProfileViewController
@synthesize profilesTableView, profiles, profileConfigs;
@synthesize availableInputMethods;

#pragma mark - Inner util methods
- (void)sortProfileNames {
    [self.profiles sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = (NSString *)obj1;
        NSString *str2 = (NSString *)obj2;
        return [str1 compare:str2];
    }];
}

//复制配置文件内容
- (void)duplicatedProfile {
    NSInteger selectedRow = self.profilesTableView.selectedRow;
    NSString *profileName = (NSString *)[self.profiles objectAtIndex:selectedRow];
    BOOL ok = [[GHDefaultManager getInstance] duplicateProfile:profileName];
    if (ok) {
        [self updateProfileList];
        [self.profilesTableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_PROFILE_LIST_CHANGED object:NULL];
    }
}

- (BOOL)profileContainAppInput:(NSString *)bundleId {
    NSArray *defaultConfigs = (NSArray *)[self.profileConfigs objectForKey:self.currentProfile];
    for (GHDefaultInfo *info in defaultConfigs) {
        if ([info.appBundleId isEqualToString:bundleId]) {
            return YES;
        }
    }
    return NO;
}

- (void)tryAddNewProfile {
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

- (void) getAlivibleInputMethods {
    [self.availableInputMethods removeAllObjects];
    self.availableInputMethods = [GHDefaultManager getAlivibleInputMethods];
}

- (void)updateProfileConfigDicts {
    self.profileConfigs = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSString *profileName in self.profiles) {
        NSMutableArray *config = [[[GHDefaultManager getInstance] getProfileInputConfig:profileName] mutableCopy];
        [self sortDefaultInputArray:config];
        [self.profileConfigs setObject:config forKey:profileName];
    }
}

- (void)addNewDefaultInput:(NSString *)profile with:(GHDefaultInfo *)info {
    NSMutableArray *infoArr = [self.profileConfigs objectForKey:profile];
    [infoArr addObject:info];
    [self sortDefaultInputArray:infoArr];
    [self.profileConfigs setObject:infoArr forKey:profile];
    [[GHDefaultManager getInstance] addNewAppInput:info forProfile:profile];
}

- (void)sortDefaultInputArray:(NSMutableArray<GHDefaultInfo *> *)arr {
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull a, id  _Nonnull b) {
        GHDefaultInfo *aInfo = (GHDefaultInfo *)a;
        GHDefaultInfo *bInfo = (GHDefaultInfo *)b;
        return [aInfo.appBundleId compare:bInfo.appBundleId];
    }];
}
- (void)updateProfileList {
    self.profiles = [[[GHDefaultManager getInstance] getProfileList] mutableCopy];
    if([self.profiles count] <= 0) {
        [self tryAddNewProfile];
    }
    [self sortProfileNames];
}

- (void)selectDefaultProfile {
    NSString *defaultProfile = [[GHDefaultManager getInstance] getDefaultProfileName];
    if ([self.profiles containsObject:defaultProfile]) {
        NSUInteger row = [self.profiles indexOfObject: defaultProfile];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
        [self.profilesTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

- (void)profileRenamed:(NSNotification *)notification {
    NSDictionary *info = [notification object];
    NSString *origin = [info objectForKey:@"origin"];
    NSString *new = [info objectForKey:@"new"];
    if ([self.profiles containsObject:origin]) {
        NSUInteger row = [self.profiles indexOfObject: origin];
        if ([self.currentProfile isEqualToString:origin]) {
            self.currentProfile = new;
        }

        [self.profiles replaceObjectAtIndex:row withObject:new];
    }
}

- (void)profilelistChanged {
    
}

- (void)defaultProfileChanged:(NSNotification *)notification {
    [self selectDefaultProfile];
}

#pragma mark - View methos
- (void)viewWillAppear {
    [super viewWillAppear];
    [self getAlivibleInputMethods];
}

- (void)awakeFromNib {
    [self.profileDetailTableView sizeLastColumnToFit];
    [self.profileDetailTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateProfileList];
    self.currentProfile = [self.profiles objectAtIndex:0];
    self.removeAppInputBtnEnabled = FALSE;
    [self updateProfileConfigDicts];
    self.availableInputMethods = [[NSMutableArray alloc] initWithCapacity:1];
    [self getAlivibleInputMethods];
    
    // Do view setup here.
    //hide header view of tables
    //these two tables have the same delegate and datasource : self
    
    [self selectDefaultProfile];
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(profilelistChanged) name:GH_NK_PROFILE_LIST_CHANGED object:NULL];
    [notiCenter addObserver:self selector:@selector(defaultProfileChanged:) name:GH_NK_DEFAULT_PROFILE_CHANGED object:NULL];
    [notiCenter addObserver:self selector:@selector(profileRenamed:) name:GH_NK_PROFILE_RENAME object:NULL];
    
    [self.removeInputConfig bind:NSEnabledBinding toObject:self withKeyPath:@"removeAppInputBtnEnabled" options:nil];
}

#pragma mark - NSTableView DataSource and Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger rowCount = 0;
    if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        rowCount = [self.profiles count];
    }
    else if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        NSArray *configs = [self.profileConfigs objectForKey:self.currentProfile];
        rowCount = [configs count];
    }
    
    return rowCount;
}

// for view-based tableview
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    //profile list
    if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        GHProfileCellView *view = [tableView makeViewWithIdentifier:TBL_CELL_IDENTIFIER_PROFILE_CELL owner:self];
        NSString *pname = (NSString *)[self.profiles objectAtIndex:row];
        [view.profileName setStringValue:pname];
        [view markSelected:(row == tableView.selectedRow)];
        return view;
    }
    else if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        [tableColumn setResizingMask:NSTableColumnAutoresizingMask];
        GHProfileContentCellView *view = (GHProfileContentCellView *)[tableView makeViewWithIdentifier:TBL_CELL_IDENTIFIER_PROFILE_CONTENT_CELL owner:self];
        NSArray *defaultConfigs = (NSArray *)[self.profileConfigs objectForKey:self.currentProfile];
        GHDefaultInfo *defaultInfo = [defaultConfigs objectAtIndex:row];
        
        view.row = row;
        [view initContent:self.availableInputMethods with:defaultInfo];
        view.profile = self.currentProfile;
        return view;
    }
    return NULL;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = (NSTableView *)[notification object];
    if([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_LIST]) {
        NSInteger selectedRow = tableView.selectedRow;
        BOOL profileSelected = selectedRow >=0 && selectedRow < [self.profiles count];
        self.btnDeleteProfile.enabled = profileSelected;
        for (int i = 0; i< tableView.numberOfRows; i++) {
            if(i < [self.profiles count]) {
                GHProfileCellView *cellView = [tableView viewAtColumn:0 row:i makeIfNecessary:YES];
                [cellView markSelected:(i==selectedRow)];
            }
        }
        if (profileSelected) {
            NSString *profileName = [self.profiles objectAtIndex:selectedRow];
            self.currentProfile = profileName;
            [self.profileDetailTableView reloadData];
        }
        self.removeAppInputBtnEnabled = FALSE;
    }
    else if ([tableView.identifier isEqualToString:TBL_IDENTIFIER_PROFILE_CONFIG_LIST]) {
        self.removeAppInputBtnEnabled = TRUE;
    }
}

- (void)tableViewColumnDidResize:(NSNotification *)notification {
    NSTableView *tableView = (NSTableView *)[notification object];
    
}

- (void)showAppSelectPanel:(BOOL)newInput {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSArray *appDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES);
    NSString *appDir = [appDirs objectAtIndex:0];
    [panel setDirectoryURL:[NSURL URLWithString:appDir]];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed

    NSWindow *window = self.view.window;
    [panel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result) {
        NSLog(@"select finished");
        if(result != NSFileHandlingPanelOKButton) {
            return;
        }
        for (NSURL *url in [panel URLs]) {
            NSBundle *selectedAppBundle =[NSBundle bundleWithURL:url];
            NSString *bundleIdentifier = [selectedAppBundle bundleIdentifier];
            if([self profileContainAppInput:bundleIdentifier]) {
                if (newInput) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:NSLocalizedString(@"duplicated_app", @"")];
                    [alert setInformativeText:NSLocalizedString(@"already_have_same_app", @"")];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert runModal];
                }

                break;
            }
            
            NSString *inputId = [[self.availableInputMethods objectAtIndex:0] objectForKey:@"id"];
            GHDefaultInfo *info = [[GHDefaultInfo alloc] initWithAppBundle:bundleIdentifier appUrl:[url path] input:inputId];
            if(newInput) {
                [self addNewDefaultInput:self.currentProfile with:info];
                [self.profileDetailTableView reloadData];
            }
            else {
                //TODO update app info
            }

            // post application
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:url, @"appUrl", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GH_APP_SELECTED" object:NULL userInfo:userInfo];

            break;
        }
    }];
}

#pragma mark IB actions

- (IBAction)addNewProfile:(id)sender {
    NSInteger selectedRow = self.profilesTableView.selectedRow;
    NSMenu *menu = [[NSMenu alloc] init];
    if (selectedRow >= 0) {
        NSString *duplicateStr = NSLocalizedString(@"duplicate_copy", @"");
        [menu addItemWithTitle:[NSString stringWithFormat:@"%@ %@",duplicateStr, [self.profiles objectAtIndex:selectedRow]] action:@selector(duplicatedProfile) keyEquivalent:@""];
        [menu addItem:[NSMenuItem separatorItem]];
    }
    NSString *addNewProfileStr = NSLocalizedString(@"add_new_profile", @"");
    [menu addItemWithTitle:addNewProfileStr action:@selector(tryAddNewProfile) keyEquivalent:@""];
    [NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:sender];
}

- (IBAction)removeProfile:(id)sender {
    if ([self.profiles count] <= 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"indicator_last_profile_cannot_remove", @"");
        [hud hide:YES afterDelay:0.5];
        return;
    }
    
    NSInteger selectedRow = self.profilesTableView.selectedRow;
    NSString *pname = (NSString *)[self.profiles objectAtIndex:selectedRow];
    BOOL ok = [[GHDefaultManager getInstance] removeProfile:pname];
    if (ok) {
        [self.profiles removeObjectAtIndex:selectedRow];
        [self.profilesTableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_PROFILE_LIST_CHANGED object:NULL];
    }
}

- (IBAction)removeAppInput:(id)sender {
    NSMutableArray *inputs = [self.profileConfigs objectForKey:self.currentProfile];
    NSInteger row = self.profileDetailTableView.selectedRow;
    GHDefaultInfo *info = [inputs objectAtIndex:row];
    [[GHDefaultManager getInstance] removeAppInput:info.appBundleId forProfile:self.currentProfile];
    [inputs removeObjectAtIndex:row];
    [self.profileDetailTableView reloadData];
}

- (IBAction)addAppInput:(id)sender {
    [self showAppSelectPanel:YES];
}

@end
