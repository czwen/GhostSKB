//
//  GHProfileTextField.m
//  GhostSKB
//
//  Created by dmx on 13/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileTextField.h"

@implementation GHProfileTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
}

- (BOOL)becomeFirstResponder {
    self.textColor = [NSColor blackColor];
    return [super becomeFirstResponder];
}

- (void)textDidChange:(NSNotification *)notification {
    NSLog(@"new value:%@", self.stringValue);
}

@end
