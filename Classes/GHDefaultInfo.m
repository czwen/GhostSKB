//
//  GHDefaultInfo.m
//  GhostSKB
//
//  Created by 丁明信 on 7/3/16.
//  Copyright © 2016 丁明信. All rights reserved.
//


#import "GHDefaultInfo.h"

@implementation GHDefaultInfo
@synthesize appBundleId;
@synthesize appUrl;
@synthesize defaultInput;

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithAppBundle:(NSString *)bundleId appUrl:(NSString *)url input:(NSString *)defaultInputId {
    if (self = [super init]) {
        self.appUrl = url;
        self.defaultInput = defaultInputId;
        self.appBundleId = bundleId;
    }
    
    return self;
}

- (void)saveToDefaultStorage {
    if (self.appUrl == NULL || self.appBundleId == NULL || self.defaultInput == NULL) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *keyBoardDefaultInputKey = [[GHDefaultManager getInstance] getPreferenceConfigKey];
    NSMutableDictionary *settings = [[userDefaults dictionaryForKey:keyBoardDefaultInputKey] mutableCopy];
    
    if(settings == NULL) {
        settings = [NSMutableDictionary dictionaryWithCapacity:1];
    }
 
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:self.appUrl, @"appUrl", self.defaultInput, @"defaultInput", self.appBundleId, @"appBundleId", nil];
    [settings setObject:info forKey:self.appBundleId];
    
    [userDefaults setObject:settings forKey:keyBoardDefaultInputKey];
    [userDefaults synchronize];
    
}

@end
