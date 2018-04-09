//
//  GHSettingTabView.m
//  GhostSKB
//
//  Created by dmx on 09/04/2018.
//  Copyright © 2018 丁明信. All rights reserved.
//

#import "GHSettingTabView.h"
#import "NSColor+Extensions.h"
#import "NSView+MyCategory.h"

@implementation GHSettingTabView
@synthesize backgroundColor,windowBackgroundColor,bezelColor;
const double kSegHeight = 32.f;
const double kRadius = 8.f;

-(void)rework {
    // For some weird reason the NSColour windowBack.. etc colours do not seem to be
    // actual colours - but just transparent. So we hardcode something here for now.
    //
    if (backgroundColor == nil) {
        self.backgroundColor = [NSColor colorWithDeviceRed:236.f/255 green:236.f/255 blue:236.f/255 alpha:1];
    }
    
    if (windowBackgroundColor == nil) {
        self.windowBackgroundColor = [NSColor colorWithDeviceRed:246.f/255 green:246.f/255 blue:246.f/255 alpha:1];
    }
    
    if (bezelColor == nil)
        self.bezelColor = [NSColor darkGrayColor];

}

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self == nil)
        return nil;
    
    [self rework];
    return self;
}

-(void)awakeFromNib {
    [self rework];
}



- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    // Pain the entire area in the background colour of the main panel
    // and then overlay a rectangle with a large 'hole' in the middle which
    // casts a shadow on this background. As to make the bezel.
    //
    CGContextSetFillColorWithColor(ctx, [backgroundColor CGColor]);
    CGContextFillRect(ctx, self.bounds);
    
    CGRect frame = self.bounds;
    CGRect inside = self.bounds;
    
    // We inset the hole by roughly half the hight of the selection bar at the
    // top - with a bit of movement down as to make it look optically pleasing
    // around the shadow cast by the bar itself.
    //
    const double S = kSegHeight / 2;
    inside.origin.x += S/2;
    inside.origin.y += S/2 + 2.0;
    inside.size.width -= S;
    inside.size.height -= 70;
    
    CGContextSetStrokeColorWithColor(ctx, [bezelColor CGColor]);
    CGContextSetFillColorWithColor(ctx, [windowBackgroundColor CGColor]);
    CGContextSaveGState(ctx);
    
    self.shadow = [[NSShadow alloc] init];
    [self.shadow setShadowColor:bezelColor /* [NSColor lightGrayColor] */];
    [self.shadow setShadowBlurRadius:3];
    [self.shadow setShadowOffset:NSMakeSize(1,-1)];
    [self.shadow set];
    
    CGPathRef roundedRectPath = [self newPathForRoundedRect:inside radius:kRadius];
    CGContextAddPath(ctx, roundedRectPath);
    CGContextAddReverseRect(ctx,frame);
    
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // The rounded textured style is semi translucent; so we
    // need to paint a bit of background behind it as to avoid
    // the bezel shining through. We also acknowledge that
    // it has round edges here.
    //
    
    NSTabViewItem *item = self.selectedTabViewItem;
    CGRect barFrame = CGRectMake(0, item.view.frame.origin.y, self.frame.size.width, self.frame.size.height);
//    barFrame.origin.x += 2.0;
    barFrame.origin.y -= 20.0;
    barFrame.size.width -= 4.0;
    barFrame.size.height -= 5.0;
    CGPathRef barPath = [self newPathForRoundedRect:barFrame radius:2.0];
    CGContextAddPath(ctx, barPath); CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // Remove shadow again - and draw a very thin outline around it all.
    //
    self.shadow = nil;
    CGContextRestoreGState(ctx);
    
    CGContextAddPath(ctx, roundedRectPath);
    CGContextClosePath(ctx);
    CGContextSetLineWidth(ctx, 0.2);
    CGContextStrokePath(ctx);
    
    // and wipe the line behind the bezel again.
//    CGContextAddPath(ctx, barPath); CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    CGPathRelease(roundedRectPath);
//    CGPathRelease(barPath);
    
    
    
    // Drawing code here.
}

@end
