//
//  MKMapView+ZoomLevel.m
//
//  Created by Paul Schmitt on 3/6/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"

@implementation MKMapView (ZoomLevel)

//----------------------------------------------------------------------------------
- (void)setZoomLevel:(double)zoomLevel
{
    [self setCenterCoordinate:self.centerCoordinate zoomLevel:zoomLevel animated:NO];
}
//----------------------------------------------------------------------------------
- (double)zoomLevel
{
    return (log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta)));// + 1;
}
//----------------------------------------------------------------------------------
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(double)zoomLevel animated:(BOOL)animated
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*self.frame.size.width/256);
    [self setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}

@end
