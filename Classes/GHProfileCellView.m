//
//  GHProfileCellView.m
//  GhostSKB
//
//  Created by dmx on 10/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileCellView.h"

@interface GHProfileCellView ()

@end

@implementation GHProfileCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:NSBackgroundStyleLight];
}

- (void)markSelected:(BOOL)isSelected {
    if (isSelected) {
        self.profileName.textColor = [NSColor whiteColor];
    }
    else {
        self.profileName.textColor = [NSColor blackColor];
    }
}

@end
