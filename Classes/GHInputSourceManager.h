//
//  GHInputSourceManager.h
//  GhostSKB
//
//  Created by dmx on 2018/5/14.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHInputSourceManager : NSObject

+ (GHInputSourceManager *)getInstance;
- (BOOL)selectInputSource:(NSString *)inputSourceId;
- (BOOL)hasInputSourceEnabled:(NSString *)inputSourceId;

@end
