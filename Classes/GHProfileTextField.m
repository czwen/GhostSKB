//
//  GHProfileTextField.m
//  GhostSKB
//
//  Created by dmx on 13/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileTextField.h"

@interface GHProfileTextField ()
- (void)beginEdit;
- (void)endEdit;
@end

@implementation GHProfileTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
}

- (void)mouseDown:(NSEvent *)event {
    if(event.clickCount == 2 && !self.isEditable) {
        [self beginEdit];
    }
    else {
        [super mouseDown:event];
    }
}

- (void)beginEdit {
    self.editable = YES;
    self.textColor = [NSColor blackColor];
    [self selectText:self.stringValue];
}

- (void)endEdit {
    self.editable = NO;
    self.textColor = [NSColor whiteColor];
    self.backgroundColor = [NSColor clearColor];
}

- (BOOL)textShouldEndEditing:(NSText *)textObject {
    return YES;
}

- (void)textDidBeginEditing:(NSNotification *)notification {
    NSLog(@"textDidBeginEditing");
}

- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    if(!self.isEditable) {
        return;
    }
    [self endEdit];
}

@end
