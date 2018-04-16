//
//  GHProfileCellView.m
//  GhostSKB
//
//  Created by dmx on 10/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileCellView.h"
#import "GHDefaultManager.h"
#import "Constant.h"
@interface GHProfileCellView ()

@end

@implementation GHProfileCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.profileName.cellView = self;
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

- (void)textFinishEditing:(NSString *)originStr withNew:(NSString *)str {
    NSLog(@"textFinishEditing %@ -- %@", originStr, str);
    BOOL ok = [[GHDefaultManager getInstance] renameProfile:originStr to:str];
    if(!ok) {
        NSLog(@"rename failed");
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_PROFILE_LIST_CHANGED object:nil];
    }
}

@end
