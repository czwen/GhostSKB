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

- (void)updatePreferenceConfigDict:(NSDictionary *)dict {
    if (dict == NULL) {
        return;
    }
    NSString *key = [[GHDefaultManager getInstance] getPreferenceConfigKey];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDictionary *)getPreferenceConfigDict {
    NSString *key = [[GHDefaultManager getInstance] getPreferenceConfigKey];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    return dict;
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
    NSDictionary *wholeDict = [defaults dictionaryRepresentation];
    
    NSString *currentKey = [NSString stringWithFormat:@"%@%ld", GH_DATA_KEY_FORMAT, (long)currentVersion];
    if ([wholeDict objectForKey:currentKey] != nil) {
        return;
    }
    
    //get the min version
    for (NSInteger i=currentVersion-1; i>0; i--) {
        NSString *key = [NSString stringWithFormat:@"%@%ld", GH_DATA_KEY_FORMAT, (long)i];
        if ([wholeDict objectForKey:key] != nil) {
            minVersion = i;
        }
        else {
            break;
        }
    }
    
    //convert from min version to current version
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

- (void)convert_2_to_3 {
    NSInteger from = 2;
    NSInteger to = 3;
    NSString *fromKey = [self getPrefrenceKeyByVersion:[@(from) stringValue]];
    NSString *toKey = [self getPrefrenceKeyByVersion:[@(to) stringValue]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [defaults dictionaryForKey:fromKey];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    newDict[@"switch_key"] = @"";
    
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
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    
    if([profilesDict objectForKey:profileName] != NULL) {
        return FALSE;
    }
    if([[profilesDict allKeys] count] <= 0) {
        [dict setObject:profileName forKey:@"currentProfile"];
    }
    [profilesDict setObject:@{@"config":@{}} forKey:profileName];
    [dict setObject:profilesDict forKey:@"profiles"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return TRUE;
}

- (BOOL)removeProfile:(NSString *)profileName {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
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
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
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
    
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    NSDictionary *newProfileDict = [[profilesDict objectForKey:profileName] mutableCopy];
    [profilesDict setObject:newProfileDict forKey:newProfileName];
    [dict setObject:profilesDict forKey:@"profiles"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return TRUE;
}

- (BOOL)renameProfile:(NSString *)from to:(NSString *) profileName {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
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
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    NSMutableDictionary *profileDict = [[profilesDict objectForKey:profile] mutableCopy];
    [profileDict setObject:bindingInfo forKey:@"keyboard_shortcut"];
    
    [profilesDict setObject:profileDict forKey:profile];
    [dict setObject:profilesDict forKey:@"profiles"];
    [defaults setObject:dict forKey:[self getPreferenceConfigKey]];
    [defaults synchronize];
    
    return TRUE;
}

- (NSDictionary *)getKeyBindings:(NSString *)profile {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    NSMutableDictionary *profileDict = [[profilesDict objectForKey:profile] mutableCopy];
    
    NSDictionary *d = [NSDictionary dictionaryWithDictionary:[profileDict objectForKey:@"keyboard_shortcut"]];
    return d;
}

- (void)addNewAppInput:(GHDefaultInfo *)info forProfile:(NSString *)profile {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    NSMutableDictionary *profileDict = [[profilesDict objectForKey:profile] mutableCopy];
    NSMutableDictionary *configDict = [[profileDict objectForKey:@"config"] mutableCopy];
    if (configDict == NULL) {
        configDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:info.appUrl, @"appUrl", info.defaultInput, @"defaultInput", info.appBundleId, @"appBundleId", nil];
    [configDict setObject:infoDict forKey:info.appBundleId];
    [profileDict setObject:configDict forKey:@"config"];
    [profilesDict setObject:profileDict forKey:profile];
    [dict setObject:profilesDict forKey:@"profiles"];
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAppInput:(NSString *)appBundleId forProfile:(NSString *)profile {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    NSMutableDictionary *profileDict = [[profilesDict objectForKey:profile] mutableCopy];
    NSMutableDictionary *configDict = [[profileDict objectForKey:@"config"] mutableCopy];
    if ([configDict objectForKey:appBundleId] != NULL) {
        [configDict removeObjectForKey:appBundleId];
        [profileDict setObject:configDict forKey:@"config"];
        [profilesDict setObject:profileDict forKey:profile];
        [dict setObject:profilesDict forKey:@"profiles"];
        
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)updateDelayTime:(double)delay {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    dict[@"switch_delay"] = @(delay);
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (double)getDelayTime {
    NSDictionary *dict = [self getPreferenceConfigDict];
    id delay = [dict objectForKey:@"switch_delay"];
    if (delay == NULL) {
        return GH_DEFAULT_DELAY_TIME;
    }
    else {
        return [delay doubleValue];
    }
}

- (BOOL)updateInputSource:(NSString *)profileName forApp:(NSString *)appBundleId inputSourceId:(NSString *)inputId {
    NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    NSMutableDictionary *profilesDict = [[dict objectForKey:@"profiles"] mutableCopy];
    NSMutableDictionary *profileDict = [[profilesDict objectForKey:profileName] mutableCopy];
    NSMutableDictionary *configDict = [[profileDict objectForKey:@"config"] mutableCopy];
    if ([configDict objectForKey:appBundleId] != NULL) {
        NSMutableDictionary *appDict = [[configDict objectForKey:appBundleId] mutableCopy];
        [appDict setObject:inputId forKey:@"defaultInput"];
        [configDict setObject:appDict forKey:appBundleId];
        [profileDict setObject:configDict forKey:@"config"];
        [profilesDict setObject:profileDict forKey:profileName];
        [dict setObject:profilesDict forKey:@"profiles"];
        
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return TRUE;
}

- (void)updateSwitchKey:(NSString *)key {
     NSMutableDictionary *dict = [[self getPreferenceConfigDict] mutableCopy];
    [dict setObject:key forKey:@"switch_key"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self getPreferenceConfigKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)switchKey {
    NSDictionary *dict = [self getPreferenceConfigDict];
    NSString* key = (NSString *)[dict objectForKey:@"switch_key"];
    return key;
}

@end
