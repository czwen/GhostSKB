//
//  GHDefaultManager.h
//  GhostSKB
//
//  Created by 丁明信 on 4/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constant.h"

@interface GHDefaultManager : NSObject

@property(assign) BOOL rememberAppLastInput;
@property(assign) NSInteger rememberAppInputExpireTime;

+ (GHDefaultManager *)getInstance;
- (NSMutableArray *)getDefaultKeyBoards;
- (NSDictionary *)getDefaultKeyBoardsDict;
- (void)removeAppInputDefault:(NSString *)appBundleId;
- (NSString *)getDefaultPrefrenceKey;
- (NSArray *)getProfileList;
- (NSMutableArray *)getProfileInputConfig:(NSString *)profileName;

@end
