//
//  SyncButton.m
//  GhostSKB
//
//  Created by dmx on 2018/4/11.
//  Copyright © 2018年 丁明信. All rights reserved.
//

#import "SyncButton.h"

@interface SyncButton ()
- (void)syncWithiCloud;
@end

@implementation SyncButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)event {
    NSMenu* newMenu = [[NSMenu allocWithZone:NSDefaultMallocZone()] initWithTitle:@"Name"];
    NSMenuItem* newItem = [[NSMenuItem alloc]initWithTitle:@"Sync" action:@selector(syncWithiCloud) keyEquivalent:@""];
    [newMenu addItem:newItem];
    [NSMenu popUpContextMenu:newMenu withEvent:event forView:self];
}

- (void)syncWithiCloud {
    NSLog(@"sync with icloud");
}


@end
