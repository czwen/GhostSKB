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
@property (assign) BOOL isSelected;
@property (assign) BOOL isDarkMode;
@end

@implementation GHProfileCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.profileName.cellView = self;
    [self checkIsDarkMode];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
}

- (void)checkIsDarkMode {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if (osxMode != nil && [osxMode isEqualToString:@"Dark"]) {
        self.isDarkMode = TRUE;
    }
    else {
        self.isDarkMode = FALSE;
    }
}

- (void)darkModeChanged:(NSNotification *)notification {
    [self checkIsDarkMode];
    [self markSelected:self.isSelected];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:NSBackgroundStyleLight];
}

- (void)markSelected:(BOOL)isSelected {
    self.isSelected = isSelected;
    NSColor *selectedColor = [NSColor greenColor];
    NSColor *normalColor = [NSColor blackColor];
    if (self.isDarkMode) {
        normalColor = [NSColor whiteColor];
    }
    if (isSelected) {
        self.profileName.textColor = selectedColor;
    }
    else {
        self.profileName.textColor = normalColor;
    }
}

- (void)textFinishEditing:(NSString *)originStr withNew:(NSString *)str {
    BOOL ok = [[GHDefaultManager getInstance] renameProfile:originStr to:str];
    if(!ok) {
        NSLog(@"rename failed");
    }
    else {
        NSDictionary *dict = @{@"origin": originStr, @"new": str};
        [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_PROFILE_RENAME object:dict];
    }
}

@end
