//
//  GHDefaultManager.h
//  GhostSKB
//
//  Created by 丁明信 on 4/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHDefaultManager : NSObject

@property(assign) BOOL rememberAppLastInput;
@property(assign) NSInteger rememberAppInputExpireTime;

+ (GHDefaultManager *)getInstance;
- (NSMutableArray *)getDefaultKeyBoards;
- (NSDictionary *)getDefaultKeyBoardsDict;
- (void)removeAppInputDefault:(NSString *)appBundleId;
- (void)recordAppLastInputSourceId:(NSString *)bundleId inputId:(NSString *)inputId;
- (NSString *)getAppLastInputSourceId:(NSString *)bundleId;
- (void)setIsRememberAppLastInput:(BOOL) remember;
- (void)setRememberAppLastExpireTime:(NSInteger )expireSeconds;

@end
