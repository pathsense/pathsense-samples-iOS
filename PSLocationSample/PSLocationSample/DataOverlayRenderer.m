//
//  DataOverlayRenderer.m
//  PSLocationTracker
//
//  Created by Paul Schmitt on 9/22/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import "DataOverlay.h"
#import "DataOverlayRenderer.h"

@implementation DataOverlayRenderer

//----------------------------------------------------------------------------------
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)ctx
{
    if ([[UIDevice currentDevice] isMultitaskingSupported] == YES) {
        UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
        if (applicationState == UIApplicationStateBackground) {
    		return;
        }
    }
    
    MKMapRect theMapRect = [[self overlay] boundingMapRect];
	if (MKMapRectIntersectsRect(theMapRect, mapRect) == NO) {
    	return;
    }

    DataOverlay *dataOverlay = nil;
    NSArray *confirmedLocations = nil;
    
	@synchronized(self) {
    	dataOverlay = (DataOverlay *)[self overlay];
        confirmedLocations = [[dataOverlay confirmedLocations] copy];
	}
    
	CGContextSaveGState(ctx);

    CGRect theRect = [self rectForMapRect:theMapRect];
    CGContextClipToRect(ctx, theRect);

    if ([confirmedLocations count]) {
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGFloat weight = 12;
        
        UIColor *color = [UIColor colorWithRed:.235 green:.671 blue:.855 alpha:1];
        
        CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, weight/zoomScale);
        BOOL moveto = YES;
        
        for (CLLocation *location in confirmedLocations) {
            MKMapPoint mapPoint = MKMapPointForCoordinate([location coordinate]);

            CGPoint point = [self pointForMapPoint:mapPoint];
            if (moveto == YES) {
                moveto = NO;
                CGContextMoveToPoint(ctx, point.x, point.y);
            } else {
                CGContextAddLineToPoint(ctx, point.x, point.y);
            }
        }
        CGContextStrokePath(ctx);
    }

    CGContextRestoreGState(ctx);
}
@end
