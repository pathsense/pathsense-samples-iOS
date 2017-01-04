//
//  UserLocationAnnotation.m
//  PSLocationTracker
//
//  Created by Paul Schmitt on 8/6/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import "UserLocationAnnotation.h"

@implementation UserLocationAnnotation
//----------------------------------------------------------------------------------
-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoordinate
{
	if (self = [super init]) {
		[self setCoordinate:inCoordinate];
	}
	return	self;
}
@end
