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
#import "GHInputSourceManager.h"
#import "AppDelegate.h"

#import <Carbon/Carbon.h>
#import <ShortcutRecorder/ShortcutRecorder.h>
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>


static GHKeybindingManager *sharedManager;

@interface GHKeybindingManager ()
- (void)defaultProfileChanged:(NSNotification *)notification;
- (void)doSetupHotKeys:(NSString *)profile;
- (void)inputHotKeyAction:(id)sender;
- (void)selectInputMethod:(NSString *)inputId;
- (void)selectPreviousInputSource;

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
    [self doSetupHotKeys:profile];
}

- (void)doSetupHotKeys:(NSString *)profile {
    GHDefaultManager *manager = [GHDefaultManager getInstance];
    PTHotKeyCenter *hcenter = [PTHotKeyCenter sharedCenter];
    
    NSMutableArray *inputMethods = [GHDefaultManager getAlivibleInputMethods];
    NSDictionary *dict = [manager getKeyBindings:profile];
    for (NSDictionary *inputMethodInfo in inputMethods) {
        NSString *inputId = [inputMethodInfo objectForKey:@"id"];
        //先解绑旧的快捷键
        PTHotKey *oldHotKey = [hcenter hotKeyWithIdentifier:inputId];
        if (oldHotKey) {
            [hcenter unregisterHotKey:oldHotKey];
        }
        
        //如果有新的快捷键，那么就绑定切换特定输入法
        NSString *inputIdRep = [inputId stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        NSDictionary *newShortcut = [dict objectForKey:inputIdRep];
        if (newShortcut && (NSNull *)newShortcut != [NSNull null])
        {
            PTHotKey *newHotKey = [PTHotKey hotKeyWithIdentifier:inputId
                                                        keyCombo:newShortcut
                                                          target:self
                                                          action:@selector(inputHotKeyAction:)];
            [hcenter registerHotKey:newHotKey];
        }
    }
}

- (void)setProfileHotKeys:(NSString *)profile {
    [self doSetupHotKeys:profile];
}

- (void)inputHotKeyAction:(id)sender {
    PTHotKey *hotKey = (PTHotKey *)sender;
    NSString *identifier = hotKey.identifier;
    [self selectInputMethod:identifier];
}

- (void)selectInputMethod:(NSString *)inputId {
    [[GHInputSourceManager getInstance] selectInputSource:inputId];
}


@end
