//
//  GHInputSourceManager.m
//  GhostSKB
//
//  Created by dmx on 2018/5/14.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHInputSourceManager.h"
#import "GHInputSource.h"
#import "GHKeybindingManager.h"
#import "GHDefaultManager.h"
#import <Carbon/Carbon.h>

static GHInputSourceManager *sharedManager;

@interface GHInputSourceManager ()

@property (strong) NSMutableDictionary *inputSources;
@property TISInputSourceRef asciiInputSource;
@property (strong) NSString *currentSwitchInputId;
- (void)updateInputSourceList;
@end

@implementation GHInputSourceManager

- (GHInputSourceManager *)init
{
    self = [super init];
    if (self) {
        self.inputSources = [[NSMutableDictionary alloc] initWithCapacity:2];
        [self updateInputSourceList];
        self.switchModifierStr = [[GHDefaultManager getInstance] switchKey];
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

+ (NSMutableArray *) getAlivibleInputMethods {
    
    NSMutableString *thisID;
    CFArrayRef availableInputs = TISCreateInputSourceList(NULL, false);
    NSUInteger count = CFArrayGetCount(availableInputs);
    NSMutableArray *inputMethods = [NSMutableArray arrayWithCapacity:2];
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
            [inputMethods addObject:dict];
        }
    }
    [inputMethods sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;
        NSString *id1 = [dict1 objectForKey:@"id"];
        NSString *id2 = [dict2 objectForKey:@"id"];
        return [id1 compare:id2];
    }];
    
    return inputMethods;
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
        [self.inputSources setObject:ghInputSource forKey:ghInputSource.inputSourceId];
    }
    self.asciiInputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
}

- (BOOL)selectNonCJKVInputSource {
    TISSelectInputSource(self.asciiInputSource);
    return TRUE;
}

- (BOOL)selectInputSource:(NSString *)inputSourceId {
    self.currentSwitchInputId = [inputSourceId copy];
    TISInputSourceRef currentInputSource = TISCopyCurrentKeyboardInputSource();
    NSString *currentInputId = (__bridge  NSString *)TISGetInputSourceProperty(currentInputSource, kTISPropertyInputSourceID);
    if ([currentInputId isEqualToString:inputSourceId]) {
        return TRUE;
    }
    CFRelease(currentInputSource);
    
    GHInputSource *ghInputSource = [self.inputSources objectForKey:inputSourceId];
    if(ghInputSource == NULL) {
        return FALSE;
    }
    static void (^switchBlock)(NSString *, GHInputSourceManager *) = ^(NSString *inputId, GHInputSourceManager *manager){
        [NSThread sleepForTimeInterval:0.16];
        if([inputId isEqualToString:manager.currentSwitchInputId]) {
            [manager selectNonCJKVInputSource];
            [manager selectPreviousInputSource];
        }
    };
    if ([ghInputSource isCJKV]) {
        [ghInputSource select];
        if([self canExecuteSwitchScript]) {
            switchBlock([inputSourceId copy], self);
        }
    }
    else {
//        [self selectPreviousInputSource];
//        [NSThread sleepForTimeInterval:0.1];
        [ghInputSource select];
    }
    return TRUE;
}

- (BOOL)hasInputSourceEnabled:(NSString *)inputSourceId {
    GHInputSource *ghInputSource = [self.inputSources objectForKey:inputSourceId];
    return ghInputSource != NULL;
}

- (void)selectPreviousInputSource {
    [self executeSwitchScript];
}

- (void)executeSwitchScript {

    // parameter
    NSAppleEventDescriptor *parameter = [NSAppleEventDescriptor descriptorWithInt32:49];
    NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
    [parameters insertDescriptor:parameter atIndex:1];

    // target
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];

    // function
    NSString *funcName = [NSString stringWithFormat:@"switch_%@", self.switchModifierStr];
    NSAppleEventDescriptor *function = [NSAppleEventDescriptor descriptorWithString:funcName];

    // event
    NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite eventID:kASSubroutineEvent targetDescriptor:target returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
    [event setParamDescriptor:parameters forKeyword:keyDirectObject];
    [event setParamDescriptor:function forKeyword:keyASSubroutineName];
    
    NSError *error;
    NSURL *scriptURL = [self switchScriptURL];
    NSUserAppleScriptTask *task = [[NSUserAppleScriptTask alloc] initWithURL:scriptURL error:&error];
    if(error) {
        NSLog(@"task init error %@", error);
    }
    
    [task executeWithAppleEvent:event completionHandler:^(NSAppleEventDescriptor * result, NSError * error) {
        if(error) {
            NSLog(@"execute error %@", error);
        }
    }];
}

- (NSURL *)switchScriptURL {
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *scriptURL = [directoryURL URLByAppendingPathComponent:@"switch.scpt"];
    return scriptURL;
}

- (BOOL)canExecuteSwitchScript {
    NSURL *url = [self switchScriptURL];
    return [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
}


@end
