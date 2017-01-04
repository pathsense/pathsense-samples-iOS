//
//  MKMapView+ZoomLevel.h
//
//  Created by Paul Schmitt on 3/6/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

@property (assign, nonatomic) NSUInteger zoomLevel;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated;

@end
