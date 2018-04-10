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

@implementation GHDefaultManager

-(id)init
{
    if (self = [super init]) {
        //do something;
    }
    
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
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

- (NSMutableArray *)getProfileInputConfig:(NSString *)profileName {
    NSDictionary *dict = [self getDefaultKeyBoardsDict];
    NSDictionary *profilesDict = (NSDictionary *)[dict objectForKey:@"profiles"];
    NSDictionary *dictOfProfile = (NSDictionary *)[profilesDict objectForKey:profileName];
    NSDictionary *configDict = [dictOfProfile objectForKey:@"config"];
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

- (NSMutableArray *)getDefaultKeyBoards {

    NSDictionary *keyBoardDefault = [self getDefaultKeyBoardsDict];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(keyBoardDefault == NULL) {
        return arr;
    }
    
    [keyBoardDefault enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
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

-(NSDictionary *)getDefaultKeyBoardsDict {
    NSString *keyBoardDefaultInputKey = [[GHDefaultManager getInstance] getDefaultPrefrenceKey];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:keyBoardDefaultInputKey];
    return dict;
}

-(void)removeAppInputDefault:(NSString *)appBundleId {
    NSDictionary *defaultInputs = [self getDefaultKeyBoardsDict];
    if(defaultInputs == NULL) {
        return;
    }
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithDictionary:defaultInputs];
    NSString *keyBoardDefaultInputKey = [[GHDefaultManager getInstance] getDefaultPrefrenceKey];
    
    if ([settings objectForKey:appBundleId] != NULL) {
        [settings removeObjectForKey:appBundleId];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:settings forKey:keyBoardDefaultInputKey];
        [userDefaults synchronize];
    }
}

- (NSString *)getDefaultPrefrenceKey {
    return [self getPrefrenceKeyByVersion:GH_DATA_VERSION];
}

- (NSString *)getPrefrenceKeyByVersion: (NSString *)version {
    NSString *key = [NSString stringWithFormat:@"%@%@", GH_DATA_KEY_FORMAT, version];
    return key;
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
    NSLog(@"convert ---");
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
    NSString *key = [self getDefaultPrefrenceKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults dictionaryForKey:key];
    NSDictionary *profilesDict = (NSDictionary *)[dict objectForKey:@"profiles"];
    if(profilesDict == NULL) {
        return NULL;
    }
    return [profilesDict allKeys];
}


@end
