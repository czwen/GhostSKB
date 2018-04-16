//
//  GHProfileTextField.h
//  GhostSKB
//
//  Created by dmx on 13/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GHProfileCellView;

@interface GHProfileTextField : NSTextField<NSTextFieldDelegate>
@property (assign) GHProfileCellView *cellView;
@property (strong) NSString *originStr;
@end
