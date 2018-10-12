//
//  GHKeybindingManager.h
//  GhostSKB
//
//  Created by dmx on 2018/4/21.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHKeybindingManager : NSObject

+ (GHKeybindingManager *)getInstance;
- (void)selectInputMethod:(NSString *)inputId;

- (void)setProfileHotKeys:(NSString *)profile;
- (void)setSystemSelectPreviousKey:(NSNumber *)key withModifier:(NSUInteger *)modifier;
@end
