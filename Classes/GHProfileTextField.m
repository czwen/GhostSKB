//
//  GHProfileTextField.m
//  GhostSKB
//
//  Created by dmx on 13/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileTextField.h"
#import "GHProfileCellView.h"

@interface GHProfileTextField ()
- (void)beginEdit;
- (void)endEdit;
@end

@implementation GHProfileTextField
@synthesize cellView, originStr;

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
    self.originStr = [NSString stringWithString:self.stringValue];
    self.editable = YES;
    self.textColor = [NSColor blackColor];
    [self selectText:self.stringValue];
}

- (void)endEdit {
    self.editable = NO;
    self.textColor = [NSColor whiteColor];
    self.backgroundColor = [NSColor clearColor];
    [self selectText:nil];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    if(!self.isEditable) {
        return;
    }
    [self endEdit];
    [self.cellView textFinishEditing:self.originStr withNew: self.stringValue];
//    [self.cellView te]
}

@end
