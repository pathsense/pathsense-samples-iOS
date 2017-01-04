//
//  UserLocationAnnotation.h
//  PSLocationTracker
//
//  Created by Paul Schmitt on 8/6/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UserLocationAnnotation : MKPointAnnotation
	-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoordinate;
@end
