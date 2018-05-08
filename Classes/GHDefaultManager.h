//
//  GHDefaultManager.h
//  GhostSKB
//
//  Created by 丁明信 on 4/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constant.h"
@class GHDefaultInfo;

@interface GHDefaultManager : NSObject

@property(assign) BOOL rememberAppLastInput;
@property(assign) NSInteger rememberAppInputExpireTime;

+ (GHDefaultManager *)getInstance;
+ (NSMutableArray *) getAlivibleInputMethods;

- (NSString *)getInputId:(NSString *)appBundleId withProfile:(nullable NSString *)profileName;
//获取键盘切换配置的key
- (NSString *)getPreferenceConfigKey;
//获取键盘切换配置的Dict
- (NSDictionary *)getPreferenceConfigDict;
- (void)updatePreferenceConfigDict:(NSDictionary *)dict;
//获取配置名的列表
- (NSArray *)getProfileList;

//根据配置名，获取配置的内容列表
- (NSMutableArray *)getProfileInputConfig:(NSString *)profileName;
//默认配置的名字
- (NSString *)getDefaultProfileName;
- (void)addNewAppInput:(GHDefaultInfo *)info forProfile:(NSString *)profile;
- (void)removeAppInput:(NSString *)appBundleId forProfile:(NSString *)profile;

- (BOOL)addProfile:(NSString *)profileName;
- (BOOL)renameProfile:(NSString*)from to:(NSString *)profileName;
- (BOOL)removeProfile:(NSString *)profileName;
- (BOOL)duplicateProfile:(NSString *)profileName;
- (BOOL)changeDefaultProfile:(NSString *)profileName;

- (BOOL)updateInputSource:(NSString *)profileName forApp:(NSString *)appBundleId inputSourceId:(NSString *)inputId;

// key bindings 相关
- (BOOL)updateKeyBindings:(NSDictionary *)bindingInfo for:(NSString *)profile;
- (NSDictionary *)getKeyBindings:(NSString *)profile;

- (void)updateDelayTime:(double)delay;
- (double)getDelayTime;

@end
