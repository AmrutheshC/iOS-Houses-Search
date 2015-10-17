
#import "MapMarkerInfoView.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 8
#define BORDER_WIDTH 0.5f

@interface MapMarkerInfoView ()

@end

@implementation MapMarkerInfoView

-(id) init {
    self = [
        [[NSBundle mainBundle] loadNibNamed: @"MapMarkerInfoView"
                                                 owner: self
                                               options: nil] objectAtIndex: 0];

    // add photo frame
    CALayer *layer = self.imageView.layer;
    [layer setBorderColor: (__bridge CGColorRef _Nullable)([UIColor whiteColor])];
    [layer setBorderWidth: 2.0f];
    [layer setShadowColor: (__bridge CGColorRef _Nullable)([UIColor grayColor])];
    [layer setShadowOpacity: 1.0f];
    [layer setShadowOffset: CGSizeMake(0, 0)];
    [layer setShadowRadius: 0.7f];
    [self.imageView setClipsToBounds: NO];
//
//
//    [self.imageView.layer setShadowPath: [UIBezierPath bezierPathWithRect: self.imageView.layer.bounds].CGPath];
//
//
//    [self.imageView.layer setShouldRasterize: YES];
//    [self.imageView.layer setRasterizationScale: [UIScreen mainScreen].scale];

    self.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    self.layer.borderWidth = BORDER_WIDTH;
    self.layer.cornerRadius = CORNER_RADIUS;

    return self;
}

@end
