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
@synthesize rememberAppLastInput;
@synthesize rememberAppInputExpireTime;

-(id)init
{
    if (self = [super init]) {
        //do something;
    }
    
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    self.rememberAppLastInput = [nc boolForKey:GH_SETTING_REMEMBER_APP_LAST_INPUT_KEY];
    self.rememberAppInputExpireTime = [nc integerForKey:GH_SETTING_REMEMBER_APP_LAST_INPUT_EXPIRE_TIME_KEY];
    return self;
}

+ (GHDefaultManager *)getInstance
{
    static dispatch_once_t onceToken;
    //保证线程安全
    dispatch_once(&onceToken, ^{
        sharedGHDefaultManager = [[self alloc] init];
    });
    
    //这是不采用GCD的单例初始化方法
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
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"gh_default_keyboards"];
    if (data == NULL) {
        return [[NSDictionary alloc] init];
    }
    NSDictionary *retrievedDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSDictionary *keyBoardDefault = [[NSDictionary alloc] initWithDictionary:retrievedDictionary];
    return keyBoardDefault;
}

-(void)removeAppInputDefault:(NSString *)appBundleId {
    NSDictionary *defaultInputs = [self getDefaultKeyBoardsDict];
    if ([defaultInputs objectForKey:appBundleId] != NULL) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:defaultInputs];
        [dict removeObjectForKey:appBundleId];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:(NSDictionary *)dict] forKey:@"gh_default_keyboards"];
        [prefs synchronize];
    }
}

- (void)recordAppLastInputSourceId:(NSString *)bundleId inputId:(NSString *)inputId
{
    if (! self.rememberAppLastInput) {
        return;
    }
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    time_t timestamp = (time_t)[[NSDate date] timeIntervalSince1970];
    [nc setInteger:(long)timestamp forKey:[NSString stringWithFormat:@"%@_last_deacitve_time", bundleId]];
    [nc setObject:inputId forKey:[NSString stringWithFormat:@"%@_last_input_id", bundleId]];
    [nc synchronize];
}

- (NSString *)getAppLastInputSourceId:(NSString *)bundleId
{
    if (! self.rememberAppLastInput) {
        return NULL;
    }
    
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    NSInteger appLastDeactiveTime = [nc integerForKey:[NSString stringWithFormat:@"%@_last_deacitve_time", bundleId]];
    time_t timestamp = (time_t)[[NSDate date] timeIntervalSince1970];
    if (timestamp - appLastDeactiveTime > self.rememberAppInputExpireTime) {
        return NULL;
    }
    NSString *lastInputId = [nc stringForKey:[NSString stringWithFormat:@"%@_last_input_id", bundleId]];
    return lastInputId;
}

- (void)setIsRememberAppLastInput:(BOOL)remember
{
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    NSString *settingKey = GH_SETTING_REMEMBER_APP_LAST_INPUT_KEY;
    [nc setBool:remember forKey:settingKey];
    [nc synchronize];
    self.rememberAppLastInput = remember;
}

- (void)setRememberAppLastExpireTime:(NSInteger )expireSeconds
{
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    [nc setInteger:expireSeconds forKey:GH_SETTING_REMEMBER_APP_LAST_INPUT_EXPIRE_TIME_KEY];
    [nc synchronize];
    self.rememberAppInputExpireTime = expireSeconds;
}


@end
