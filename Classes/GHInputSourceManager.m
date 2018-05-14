//
//  GHInputSourceManager.m
//  GhostSKB
//
//  Created by dmx on 2018/5/14.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHInputSourceManager.h"
#import "GHInputSource.h"
#import <Carbon/Carbon.h>

static GHInputSourceManager *sharedManager;

@interface GHInputSourceManager ()

@property (strong) NSMutableDictionary *inputSources;
@property (strong) GHInputSource *noCJKVInputSource;
- (void)updateInputSourceList;
@end

@implementation GHInputSourceManager

- (GHInputSourceManager *)init
{
    self = [super init];
    if (self) {
        self.inputSources = [[NSMutableDictionary alloc] initWithCapacity:2];
        [self updateInputSourceList];
    }
    return self;
}

+ (GHInputSourceManager *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GHInputSourceManager alloc] init];
    });
    return sharedManager;
}

- (void)updateInputSourceList {
    if(self.inputSources != NULL) {
        [self.inputSources removeAllObjects];
    }
    
    
    NSDictionary *property=[NSDictionary dictionaryWithObject:(NSString*)kTISCategoryKeyboardInputSource
                                                       forKey:(NSString*)kTISPropertyInputSourceCategory];
    CFArrayRef availableInputs = TISCreateInputSourceList((__bridge CFDictionaryRef)property, FALSE);
    NSUInteger count = CFArrayGetCount(availableInputs);
    for (int i = 0; i < count; i++) {
        TISInputSourceRef inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(availableInputs, i);
        GHInputSource *ghInputSource = [[GHInputSource alloc] initWithInputSource:inputSource];
        if(![ghInputSource isCJKV]) {
            self.noCJKVInputSource = ghInputSource;
        }
        [self.inputSources setObject:ghInputSource forKey:ghInputSource.inputSourceId];
    }
}

- (BOOL)selectInputSource:(NSString *)inputSourceId {
    
    GHInputSource *ghInputSource = [self.inputSources objectForKey:inputSourceId];
    if(ghInputSource == NULL) {
        return FALSE;
    }
    if ([ghInputSource isCJKV]) {
        [ghInputSource select];
    }
    else {
        [ghInputSource select];
    }
    return TRUE;
}

- (BOOL)hasInputSourceEnabled:(NSString *)inputSourceId {
    GHInputSource *ghInputSource = [self.inputSources objectForKey:inputSourceId];
    return ghInputSource != NULL;
}

@end
