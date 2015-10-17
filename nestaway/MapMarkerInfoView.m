
#import "MapMarkerInfoView.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 7

@interface MapMarkerInfoView ()

@end

@implementation MapMarkerInfoView

-(id) init {
    self = [
        [[NSBundle mainBundle] loadNibNamed: @"MapMarkerInfoView"
                                                 owner: self
                                               options: nil] objectAtIndex: 0];
    self.layer.cornerRadius = CORNER_RADIUS;

    return self;
}

@end
