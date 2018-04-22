//
//  GHProfileContentCellView.m
//  GhostSKB
//
//  Created by dmx on 10/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileContentCellView.h"

@implementation GHProfileContentCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)initContent:(NSArray *)inputMethodsInfoArray with:(GHDefaultInfo *)defaultInfo {
    
    if (defaultInfo.defaultInput == NULL) {
        NSString *defaultInputId = (NSString *)[[inputMethodsInfoArray objectAtIndex:0] objectForKey:@"id"];
        defaultInfo.defaultInput = defaultInputId;
    }
    
    
    if (defaultInfo.appUrl != NULL && defaultInfo.appBundleId != NULL){
        NSURL *appUrl = [NSURL fileURLWithPath:defaultInfo.appUrl];
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[appUrl path]];
        NSBundle *appBundle =[NSBundle bundleWithPath:[appUrl path]];
        NSString *appName = [[NSFileManager defaultManager] displayNameAtPath: [appBundle bundlePath]];
        //防止app被删除导致的错误
        if (appName != NULL) {
            self.appName.stringValue = appName;
            self.appButton.image = icon;
        }
    }
    else {
        self.appButton.image = NULL;
        self.appName.stringValue = @"";
    }

    
    if ([self.inputMethodsPopButton.menu numberOfItems] <= 0) {
        for (int i=0; i<[inputMethodsInfoArray count]; i++) {
            NSDictionary *inputInfo = inputMethodsInfoArray[i];
            NSString *inputName = [inputInfo objectForKey:@"inputName"];
            NSMenuItem *item = [self.inputMethodsPopButton.menu
                                addItemWithTitle:inputName
                                action:NULL
                                keyEquivalent:@""];
            item.representedObject = self;
        }
    }
    for (NSDictionary *info in inputMethodsInfoArray) {
        if ([[info objectForKey:@"id"] isEqualToString:defaultInfo.defaultInput]) {
            [self.inputMethodsPopButton selectItemWithTitle:[info objectForKey:@"inputName"]];
        }
    }

}

@end
