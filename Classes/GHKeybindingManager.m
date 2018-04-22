//
//  GHKeybindingManager.m
//  GhostSKB
//
//  Created by dmx on 2018/4/21.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import "GHKeybindingManager.h"
#import "Constant.h"
#import "GHDefaultManager.h"

#import <ShortcutRecorder/ShortcutRecorder.h>
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>


static GHKeybindingManager *sharedManager;

@interface GHKeybindingManager ()
- (void)defaultProfileChanged:(NSNotification *)notification;
@end

@implementation GHKeybindingManager


- (GHKeybindingManager *)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(defaultProfileChanged:) name:GH_NK_DEFAULT_PROFILE_CHANGED object:NULL];
    }
    return self;
}

+ (GHKeybindingManager *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GHKeybindingManager alloc] init];
    });
    return sharedManager;
}

- (void)defaultProfileChanged:(NSNotification *)notification {
    NSString *profile = [notification object];
    
    GHDefaultManager *manager = [GHDefaultManager getInstance];
    NSDictionary *dict = [manager getKeyBindings:profile];
    
    PTHotKeyCenter *center = [PTHotKeyCenter sharedCenter];
    PTHotKey *oldHotKey = [center hotKeyWithIdentifier:profile];
    if (oldHotKey) {
        [center unregisterHotKey:oldHotKey];
    }
    
//    if (newShortcut && (NSNull *)newShortcut != [NSNull null])
//    {
//        PTHotKey *newHotKey = [PTHotKey hotKeyWithIdentifier:aKeyPath
//                                                    keyCombo:newShortcut
//                                                      target:self
//                                                      action:@selector(ping:)];
//        [hotKeyCenter registerHotKey:newHotKey];
//    }
}

@end
