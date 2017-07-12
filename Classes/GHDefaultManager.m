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
    NSString *key = [NSString stringWithFormat:@"gh_default_keyboards_%@", GH_DATA_VERSION];
    return key;
}

@end
