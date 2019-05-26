//
//  ObservationAnnotation.m
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import "ObservationAnnotation.h"

@implementation ObservationAnnotation

//----------------------------------------------------------------------------------
- (instancetype) initWithCoordinate:(CLLocationCoordinate2D)inCoordinate
{
	if (self = [super init]) {
		[self setCoordinate:inCoordinate];
	}
	return self;
}
@end
