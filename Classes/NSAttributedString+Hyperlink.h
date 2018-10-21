//
//  NSObject+NSAttributedString_Hyperlink.h
//  GhostSKB
//
//  Created by mingxin.ding on 2018/10/21.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

NS_ASSUME_NONNULL_END
