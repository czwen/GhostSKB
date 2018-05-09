//
//  GHSyncViewController.m
//  GhostSKB
//
//  Created by dmx on 16/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

//TODO delete all config from icloud

#import "GHSyncViewController.h"
#import "GHDefaultManager.h"
#import "MBProgressHUD.h"

#import <CloudKit/CloudKit.h>

@interface GHSyncViewController ()
- (BOOL)isiCloudLoggin;
- (void)openiCloudPrefPane;
- (void)toggleViews:(BOOL)hidden;
- (void)showAccessbilityDialog;
- (void)refreshView;
- (void)showNotLoginAlert;
@end

@implementation GHSyncViewController

- (void)awakeFromNib {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.loginButton.title = NSLocalizedString(@"click_to_login_icloud", @"");
    self.uploadButton.title = NSLocalizedString(@"upload_to_icloud", @"");
    self.downloadButton.title = NSLocalizedString(@"download_from_icloud", @"");
    [self refreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector (iCloudAccountAvailabilityChanged:)
                                                 name: NSUbiquityIdentityDidChangeNotification
                                               object: nil];
}

- (void)iCloudAccountAvailabilityChanged:(NSNotification *)notification {
    if ([self isiCloudLoggin]) {
        [self animateRefreshView];
    }
    else {
        [self refreshView];
    }
}

- (void)refreshView {
    BOOL initViewHidden = TRUE;
    if ([self isiCloudLoggin]) {
        initViewHidden = FALSE;
    }
    else {
        initViewHidden = TRUE;
    }
    [self toggleViews:initViewHidden];
}

- (void)showNotLoginAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"iCloud logged out!"];
    [alert setInformativeText:@"Must login icloud in System Preference before sync"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

- (void)showAccessbilityDialog {
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1090
    if (AXIsProcessTrustedWithOptions) {
        // 10.9 and later
        const void * keys[] = { kAXTrustedCheckOptionPrompt };
        const void * values[] = { kCFBooleanTrue };
        
        CFDictionaryRef options = CFDictionaryCreate(
                                                     kCFAllocatorDefault,
                                                     keys,
                                                     values,
                                                     sizeof(keys) / sizeof(*keys),
                                                     &kCFCopyStringDictionaryKeyCallBacks,
                                                     &kCFTypeDictionaryValueCallBacks);
        
        AXIsProcessTrustedWithOptions(options);
    }
#else
    
#endif

}

- (IBAction)downloadFromICloud:(id)sender {
    if (![self isiCloudLoggin]) {
        [self showNotLoginAlert];
        return;
    }
    //indicator
    MBProgressHUD *hud = [self showProgress:NSLocalizedString(@"indicator_downloading", @"")];
    
    CKDatabase *privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    CKRecordID *artworkRecordID = [[CKRecordID alloc] initWithRecordName:@"profile_content"];
    [privateDatabase fetchRecordWithID:artworkRecordID completionHandler:^(CKRecord *artworkRecord, NSError *error) {
        if (error) {
            //处理错误
        }
        else {
            // 成功获取到数据
            NSData *data = [artworkRecord objectForKey:@"configDict"];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            [[GHDefaultManager getInstance] updatePreferenceConfigDict:dict];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hide:YES afterDelay:0.2];
            });
            
        }
    }];
    
}

- (MBProgressHUD *)showProgress:(NSString *)text {
    CGSize hudSize = CGSizeMake(280, 200);
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithFrame: CGRectMake(center.x-hudSize.width/2, center.y-hudSize.height/2, hudSize.width, hudSize.height)];
    
    hud.minSize = hudSize;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = text;
    [self.view addSubview:hud];
    [hud show:YES];
    return hud;
}

- (IBAction)uploadToICloud:(id)sender {
    if (![self isiCloudLoggin]) {
        [self showNotLoginAlert];
        return;
    }

    NSDictionary *dict = [[GHDefaultManager getInstance] getPreferenceConfigDict];
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:@"profile_content"];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"profile_v2" recordID:recordId];
    record[@"configDict"] = data;
    //私有数据库
    CKContainer *myContainer = [CKContainer defaultContainer];
    CKDatabase  *privateDatabase = [myContainer privateCloudDatabase];
    
    //indicator
    MBProgressHUD *hud = [self showProgress:NSLocalizedString(@"indicator_uploading", @"")];
    
    CKModifyRecordsOperation *modifyRecords = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:NULL];
    modifyRecords.savePolicy = CKRecordSaveAllKeys;
    modifyRecords.qualityOfService = NSQualityOfServiceUserInitiated;
    modifyRecords.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
        if (error) {
//            NSLog(@"modify error:%@", error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES afterDelay:0.2];
        });
    };
    
    [privateDatabase addOperation:modifyRecords];
    
}

- (IBAction)tryOpeniCloudPrefPane:(id)sender {
    [self openiCloudPrefPane];
}

- (BOOL)isiCloudLoggin {
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    return token != NULL;
}

- (void)openiCloudPrefPane {
    
    NSDictionary* errorDict;
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
                                   @"\
                                   tell application \"System Preferences\"\n\
                                   activate\n\
                                   set the current pane to pane id \"com.apple.preferences.icloud\"\n\
                                   end tell"];
    [scriptObject executeAndReturnError: &errorDict];
}

- (void)toggleViews:(BOOL)hidden {
    for (NSView *view in self.view.subviews) {
        if (view.tag <= 0) {
            view.hidden = hidden;
        }
        else if (view.tag == 1) {
            view.hidden = !hidden;
        }
    }
}

- (void)animateRefreshView {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.7;
        self.loginButton.animator.alphaValue = 0.5;
        CGRect frame = self.loginButton.frame;
        self.loginButton.animator.frame = CGRectMake(self.view.bounds.size.width+30, frame.origin.y, frame.size.width, frame.size.height);
    } completionHandler:^{
        [self toggleViews:FALSE];
    }];
}
@end
