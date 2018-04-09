//
//  GHSettingTabView.h
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface GHSettingTabView : NSTabView {
    NSColor *backgroundColor, *windowBackgroundColor, *bezelColor;
}

@property (retain) NSColor *backgroundColor, *windowBackgroundColor, *bezelColor;
@end
