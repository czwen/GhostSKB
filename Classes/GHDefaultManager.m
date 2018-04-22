//
//  GHDefaultManager.m
//  GhostSKB
//
//  Created by 丁明信 on 4/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import "GHDefaultManager.h"
#import "GHDefaultInfo.h"
#import "Constant.h"
#import <Carbon/Carbon.h>
static GHDefaultManager *sharedGHDefaultManager = nil;

@interface GHDefaultManager ()
- (NSDictionary *)getProfileInputConfigDict:(NSString *)profileName;
@end

@implementation GHDefaultManager

-(id)init
{
    if (self = [super init]) {
        //do something;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    [self tryConvertPrefrences];
    return self;
}

+ (GHDefaultManager *)getInstance
{
    static dispatch_once_t onceToken;
    //保证线程安全
    dispatch_once(&onceToken, ^{
        sharedGHDefaultManager = [[self alloc] init];
    });
    
    return sharedGHDefaultManager;
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
    return inputMethods;
}


- (NSDictionary *)getProfileInputConfigDict:(NSString *)profileName {
    NSDictionary *dict = [self getPreferenceConfigDict];
    NSDictionary *profilesDict = (NSDictionary *)[dict objectForKey:@"profiles"];
    NSDictionary *dictOfProfile = (NSDictionary *)[profilesDict objectForKey:profileName];
    NSDictionary *configDict = [dictOfProfile objectForKey:@"config"];
    return configDict;
}

- (NSMutableArray *)getProfileInputConfig:(NSString *)profileName {
    NSDictionary *configDict = [self getProfileInputConfigDict:profileName];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(configDict == NULL) {
        return arr;
    }
    
    [configDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        GHDefaultInfo *info = [[GHDefaultInfo alloc] initWithAppBundle:[object objectForKey:@"appBundleId"]
                                                                appUrl:[[object objectForKey:@"appUrl"] description]
                                                                 input:[object objectForKey:@"defaultInput"]];
        [arr addObject:info];
    }];
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull a, id  _Nonnull b) {
        GHDefaultInfo *aInfo = (GHDefaultInfo *)a;
        GHDefaultInfo *bInfo = (GHDefaultInfo *)b;
        return [aInfo.appBundleId compare:bInfo.appBundleId];
    }];
    return arr;
}

-(NSDictionary *)getPreferenceConfigDict {
    NSString *key = [[GHDefaultManager getInstance] getPreferenceConfigKey];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    return dict;
}

-(void)removeAppInputDefault:(NSString *)appBundleId {
    NSDictionary *defaultInputs = [self getPreferenceConfigDict];
    if(defaultInputs == NULL) {
        return;
    }
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithDictionary:defaultInputs];
    NSString *keyBoardDefaultInputKey = [[GHDefaultManager getInstance] getPreferenceConfigKey];
    
    if ([settings objectForKey:appBundleId] != NULL) {
        [settings removeObjectForKey:appBundleId];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:settings forKey:keyBoardDefaultInputKey];
        [userDefaults synchronize];
    }
}

- (NSString *)getPreferenceConfigKey {
    return [self getPrefrenceKeyByVersion:GH_DATA_VERSION];
}

- (NSString *)getDefaultProfileName {
    NSDictionary *dict = [self getPreferenceConfigDict];
    NSString *currentProfile = (NSString *)[dict objectForKey:@"currentProfile"];
    return currentProfile;
}

- (NSString *)getPrefrenceKeyByVersion: (NSString *)version {
    NSString *key = [NSString stringWithFormat:@"%@%@", GH_DATA_KEY_FORMAT, version];
    return key;
}

- (NSString *)getInputId:(NSString *)appBundleId withProfile:(nullable NSString *)profileName {
    if (profileName == NULL) {
        profileName = [self getDefaultProfileName];
    }
    NSDictionary *dict = [self getProfileInputConfigDict:profileName];
    NSDictionary *infoDict = [dict objectForKey:appBundleId];
    NSString *inputId = (NSString *)[infoDict objectForKey:@"defaultInput"];
    return inputId;
}

//convert versions from low version to high version
- (void)tryConvertPrefrences {
    NSInteger currentVersion = [GH_DATA_VERSION integerValue];
    NSInteger minVersion = 1;
    NSInteger currentMinVersion = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSInteger i=minVersion; i<currentVersion; i++) {
        currentMinVersion = i+1;
        NSString *key = [self getPrefrenceKeyByVersion:[@(currentMinVersion) stringValue]];
        NSDictionary *dict = [defaults dictionaryForKey:key];
        if (dict == NULL) {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"convert_%ld_to_%ld", i, currentMinVersion]);
            if (selector != NULL && [self respondsToSelector:selector]) {
                [self performSelector:selector];
            }
        }
        else {
            for (NSString *key in dict) {
                NSLog(@"key %@", key);
            }
        }
    }
}

- (void)convert_1_to_2 {
    NSInteger from = 1;
    NSInteger to = 2;
    NSString *fromKey = [self getPrefrenceKeyByVersion:[@(from) stringValue]];
    NSString *toKey = [self getPrefrenceKeyByVersion:[@(to) stringValue]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults dictionaryForKey:fromKey];
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:dict, @"config", nil];
    NSDictionary *profilesDict = [NSDictionary dictionaryWithObjectsAndKeys:configDict, @"default", nil];
    NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:profilesDict, @"profiles", @"default", @"currentProfile", nil];

    [defaults setObject:newDict forKey:toKey];
    [defaults synchronize];
}

- (NSArray *)getProfileList {
    NSString *key = [self getPreferenceConfigKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults dictionaryForKey:key];
    NSDictionary *profilesDict = (NSDictionary *)[dict objectForKey:@"profiles"];
    if(profilesDict == NULL) {
        return NULL;
    }
    return [profilesDict allKeys];
}

- (BOOL)addProfile:(NSString *)profileName {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    if([profilesDict objectForKey:profileName] != NULL) {
        return FALSE;
    }
    [profilesDict setObject:@{@"config":@{}} forKey:profileName];
    [dict setObject:profilesDict forKey:@"profiles"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return TRUE;
}

- (BOOL)removeProfile:(NSString *)profileName {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    if([profilesDict objectForKey:profileName] == NULL) {
        return TRUE;
    }
    [profilesDict removeObjectForKey:profileName];
    [dict setObject:profilesDict forKey:@"profiles"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return TRUE;
}

- (BOOL)changeDefaultProfile:(NSString *)profileName {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    if([profilesDict objectForKey:profileName] == NULL) {
        return FALSE;
    }
    [dict setObject:profileName forKey:@"currentProfile"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return TRUE;
}

- (BOOL)duplicateProfile:(NSString *)profileName {
    NSArray *profiles = [self getProfileList];
    NSString *newProfileName = [NSString stringWithFormat:@"%@_dup", profileName];
    
    int count = 1;
    for (NSString *pname in profiles) {
        if ([pname containsString:[NSString stringWithFormat:@"%@_%d", newProfileName, count]]) {
            count += 1;
        }
        else if ([pname containsString:newProfileName]) {
            count += 1;
        }
    }
    newProfileName = [NSString stringWithFormat:@"%@_%d", newProfileName, count];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    NSDictionary *newProfileDict = [NSDictionary dictionaryWithDictionary:[profilesDict objectForKey:profileName]];
    [profilesDict setObject:newProfileDict forKey:newProfileName];
    [dict setObject:profilesDict forKey:@"profiles"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return TRUE;
}

- (BOOL)renameProfile:(NSString *)from to:(NSString *) profileName {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    NSDictionary *targetDict = [profilesDict objectForKey:from];
    if(targetDict == NULL) {
        return FALSE;
    }
    NSDictionary *copyedDict = [NSDictionary dictionaryWithDictionary:targetDict];
    [profilesDict removeObjectForKey:from];
    [profilesDict setObject:copyedDict forKey:profileName];
    [dict setObject:profilesDict forKey:@"profiles"];
    
    if([from isEqualToString:[self getDefaultProfileName]]) {
        [dict setObject:profileName forKey:@"currentProfile"];
    }

    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return TRUE;
}

- (BOOL)updateKeyBindings:(NSDictionary *)bindingInfo for:(NSString *)profile {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    NSMutableDictionary *profileDict = [NSMutableDictionary dictionaryWithDictionary:[profilesDict objectForKey:profile]];
    [profileDict setObject:bindingInfo forKey:@"keyboard_shortcut"];
    
    [profilesDict setObject:profileDict forKey:profile];
    [dict setObject:profilesDict forKey:@"profiles"];
    [defaults setObject:dict forKey:[self getPreferenceConfigKey]];
    [defaults synchronize];
    
    return TRUE;
}

- (NSDictionary *)getKeyBindings:(NSString *)profile {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getPreferenceConfigDict]];
    NSMutableDictionary *profilesDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"profiles"]];
    NSMutableDictionary *profileDict = [NSMutableDictionary dictionaryWithDictionary:[profilesDict objectForKey:profile]];
    
    NSDictionary *d = [NSDictionary dictionaryWithDictionary:[profileDict objectForKey:@"keyboard_shortcut"]];
    return d;
}

@end
