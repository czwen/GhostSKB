//
//  GHAdvanceInputShortcutCellView.h
//  GhostSKB
//
//  Created by dmx on 19/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface GHAdvanceInputShortcutCellView : NSTableCellView
@property (weak) IBOutlet SRRecorderControl *recorderControl;

@end
