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
//    self.delegate = self;
}

//- (BOOL)becomeFirstResponder {
//    self.textColor = [NSColor blackColor];
//    NSLog(@"becomeFirstResponder");
//    
//    return [super becomeFirstResponder];
//}

//- (BOOL)resignFirstResponder {
//    self.textColor = [NSColor whiteColor];
//    NSLog(@"resignFirstResponder");
//    return [super resignFirstResponder];
//}

- (BOOL)textShouldBeginEditing:(NSText *)textObject {
    NSLog(@"textShouldBeginEditing----");
    return [super textShouldBeginEditing:textObject];
}

- (void)textDidBeginEditing:(NSNotification *)notification {
    NSLog(@"textDidBeginEditing");
}

- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    NSLog(@"textDidEndEditing");
    self.textColor = [NSColor whiteColor];
}

@end
