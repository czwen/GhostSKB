//
//  GHProfileContentCellView.m
//  GhostSKB
//
//  Created by dmx on 10/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHProfileContentCellView.h"
#import "Constant.h"

@interface GHProfileContentCellView ()
@property (nonatomic, strong) GHDefaultInfo *defaultInfo;
@property (nonatomic, strong) NSArray *inputMethods;
@end

@implementation GHProfileContentCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)initContent:(NSArray *)inputMethodsInfoArray with:(GHDefaultInfo *)defaultInfo {
    self.defaultInfo = defaultInfo;
    self.inputMethods = [inputMethodsInfoArray copy];
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
                                action:@selector(onInputSourceChanged:)
                                keyEquivalent:@""];
            
            [item setTarget:self];
            item.representedObject = self.inputMethodsPopButton;
        }
    }
    for (NSDictionary *info in inputMethodsInfoArray) {
        if ([[info objectForKey:@"id"] isEqualToString:defaultInfo.defaultInput]) {
            [self.inputMethodsPopButton selectItemWithTitle:[info objectForKey:@"inputName"]];
        }
    }
}

- (void)onInputSourceChanged:(id)sender {
    if (self.profile == NULL || [self.profile length] == 0) {
        return;
    }
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *inputName = item.title;
    NSString *inputId = NULL;
    for (NSDictionary *dict in self.inputMethods) {
        if ([[dict objectForKey:@"inputName"] isEqualToString:inputName]) {
            inputId = [dict objectForKey:@"id"];
            break;
        }
    }
    
    if(inputId == NULL) {
        return;
    }
    
    NSString *appBundleId = [self.defaultInfo appBundleId];
    [[GHDefaultManager getInstance] updateInputSource:self.profile forApp:appBundleId inputSourceId:inputId];
    NSDictionary *dict = @{@"profile": self.profile, @"input_source_id": inputId, @"app_id": appBundleId};
    [[NSNotificationCenter defaultCenter] postNotificationName:GH_NK_APP_INPUT_SOURCE_CHANGED object:dict];
}

@end
