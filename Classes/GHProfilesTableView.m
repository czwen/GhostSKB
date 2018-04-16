//
//  GHProfilesTableView.m
//  GhostSKB
//
//  Created by dmx on 16/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfilesTableView.h"
#import "GHProfileTextField.h"

@implementation GHProfilesTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event {
    if([responder isKindOfClass:[GHProfileTextField class]]) {
        return YES;
    }
    return [super validateProposedFirstResponder:responder forEvent:event];
}

@end
