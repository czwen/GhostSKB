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
    
//    //这是不采用GCD的单例初始化方法
//    @synchronized(self)
//    {
//        if (sharedGHDefaultManager == nil)
//        {
//            sharedGHDefaultManager = [[self alloc] init];
//        }
//    }
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
    NSString *inputId = [[infoDict objectForKey:@"defaultInput"] description];
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
//        [defaults removeObjectForKey:key];
//        [defaults synchronize];
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


@end
