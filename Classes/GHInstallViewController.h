//
//  GHInstallViewController.h
//  GhostSKB
//
//  Created by mingxin.ding on 2018/10/9.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GHInstallViewController : NSViewController<NSOpenSavePanelDelegate>
- (IBAction)installScript:(id)sender;
- (IBAction)getSystemShortcuts:(id)sender;
@property (weak) IBOutlet NSTextField *installStatusLabel;
@property (weak) IBOutlet NSTextField *shortcutStatusLabel;

@end

NS_ASSUME_NONNULL_END
