//
//  GHSyncViewController.m
//  GhostSKB
//
//  Created by dmx on 16/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHSyncViewController.h"
#import <CloudKit/CloudKit.h>

@interface GHSyncViewController ()
- (BOOL)isiCloudLoggin;
- (void)openiCloudPrefPane;
- (void)toggleViews:(BOOL)hidden;
- (void)showAccessbilityDialog;
- (void)refreshView;
@end

@implementation GHSyncViewController

- (void)awakeFromNib {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshView];
    
    if (![self isiCloudLoggin]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while(TRUE) {
                if ([self isiCloudLoggin]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self animateRefreshView];
                    });
                    break;
                }
                sleep(0.3);
            }
        });
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
    NSLog(@"download config");
}

- (IBAction)uploadToICloud:(id)sender {
    NSLog(@"upload config");
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
