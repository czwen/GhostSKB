//
//  GHInputSource.m
//  GhostSKB
//
//  Created by dmx on 2018/5/14.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHInputSource.h"

@implementation GHInputSource


- (id)initWithInputSource:(TISInputSourceRef)inputSource {
    self = [super init];
    if (self) {
        NSArray *sourceLanguages = (__bridge NSArray*)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceLanguages);
        NSNumber *pCanSelect = (__bridge NSNumber *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsSelectCapable);
        NSNumber *pCanEnable = (__bridge NSNumber *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsEnableCapable);
        NSMutableString *inputSourceId = (__bridge NSMutableString *)(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID));
        self.sourceLanguages = [NSArray arrayWithArray:sourceLanguages];
        self.inputSourceId = [inputSourceId copy];
        self.canSelect = [pCanSelect boolValue];
        self.canEnable = [pCanEnable boolValue];
        self.inputSource = inputSource;
    }
    return self;
}

- (BOOL)isCJKV {
    if (self.sourceLanguages == NULL || [self.sourceLanguages count] <=0) {
        return FALSE;
    }
    NSString *lang = [self.sourceLanguages objectAtIndex:0];
    if ([lang isEqualToString:@"ko"] || [lang isEqualToString:@"ja"] || [lang isEqualToString:@"vi"] || [lang hasPrefix:@"zh"]) {
        return TRUE;
    }
    return FALSE;
}

- (void)select {
//    if (self.canEnable) {
//        NSLog(@"select -- canEnable");
//        TISEnableInputSource(self.inputSource);
//    }
    if(self.canSelect) {
        NSLog(@"select -- canSelect");
        if(TISSelectInputSource(self.inputSource) == noErr) {
            NSLog(@"select -- ok");
        }
        else {
            NSLog(@"select -- error");
        }
        
    }
    
}

@end
