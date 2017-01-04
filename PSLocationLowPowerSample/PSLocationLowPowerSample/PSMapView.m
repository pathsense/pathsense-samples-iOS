//
//  PSMapView.m
//  PSLocationTracker
//
//  Created by Paul Schmitt on 9/17/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import "PSMapView.h"

@implementation PSMapView


//----------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_userAdjusted = YES;
	[super touchesBegan:touches withEvent:event];
}
@end
