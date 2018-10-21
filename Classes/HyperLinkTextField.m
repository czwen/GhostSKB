//
//  HyperLinkTextField.m
//  GhostSKB
//
//  Created by mingxin.ding on 2018/10/21.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "HyperLinkTextField.h"

@implementation HyperLinkTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)event {
    NSRange range = NSMakeRange(0, self.attributedStringValue.length);
    NSDictionary *attrDict = [self.attributedStringValue attributesAtIndex:0 effectiveRange:&range];
    NSString *urlStr = [attrDict objectForKey:NSLinkAttributeName];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
@end
