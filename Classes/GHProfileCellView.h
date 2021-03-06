//
//  GHProfileCellView.h
//  GhostSKB
//
//  Created by dmx on 10/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GHProfileTextField.h"

@interface GHProfileCellView : NSTableCellView<NSTextFieldDelegate>
@property (weak) IBOutlet GHProfileTextField *profileName;

- (void)markSelected:(BOOL) isSelected;
- (void)textFinishEditing:(NSString *)originStr withNew:(NSString *)str;

@end
