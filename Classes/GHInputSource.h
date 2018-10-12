//
//  GHInputSource.h
//  GhostSKB
//
//  Created by dmx on 2018/5/14.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
@interface GHInputSource : NSObject

@property(strong) NSString *inputSourceId;
@property(assign) BOOL canSelect;
@property(assign) BOOL canEnable;
@property(strong) NSArray *sourceLanguages;
@property TISInputSourceRef inputSource;

- (id)initWithInputSource:(TISInputSourceRef)inputSource;
- (BOOL)isCJKV;
- (void)select;
@end
