//
//  DataOverlay.m
//  PSLocationTracker
//
//  Created by Paul Schmitt on 9/22/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import "DataOverlay.h"

@interface DataOverlay ()
{
}
@end

@interface DataOverlay ()
{
	CLLocationCoordinate2D 	__center;
	MKMapRect				__mapBounds;
}
@end

#define kMetersPerMile		1609.34
#define kRadius				20 * kMetersPerMile

@implementation DataOverlay

//----------------------------------------------------------------------------------
-(instancetype ) initWithLocation:(CLLocation *)location
{
	if (self = [super init]) {
        __center = [location coordinate];
        
        //this is very crude and will not work accross the global -- but this is just a sample - so its all good!
        CLLocationCoordinate2D topRightCoord = CLLocationCoordinate2DMake(__center.latitude + .25, __center.longitude + .25);
        CLLocationCoordinate2D bottomLeftCoord = CLLocationCoordinate2DMake(__center.latitude - .25, __center.longitude - .25);
        
        //Latitue and longitude for each corner point
        MKMapPoint upperLeft   = MKMapPointForCoordinate(CLLocationCoordinate2DMake(topRightCoord.latitude, bottomLeftCoord.longitude));
        MKMapPoint upperRight  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(topRightCoord.latitude, topRightCoord.longitude));
        MKMapPoint bottomLeft  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(bottomLeftCoord.latitude, bottomLeftCoord.longitude));
        
        //Building a map rect that represents the image projection on the map
        __mapBounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - upperRight.x), fabs(upperLeft.y - bottomLeft.y));
    }
    return self;
}
//----------------------------------------------------------------------------------
-(void) dealloc
{
	[self clear];
}
//----------------------------------------------------------------------------------
- (BOOL) containsLocation:(CLLocation *)location
{
	CLLocationCoordinate2D coord = [location coordinate];
    MKMapPoint pt = MKMapPointForCoordinate(coord);
	BOOL result = MKMapRectContainsPoint(__mapBounds, pt);
    return result;
}
//----------------------------------------------------------------------------------
- (void) clear
{
    @synchronized(self) {
        [self setLocations:nil];
    }
}
//----------------------------------------------------------------------------------
-(CLLocationCoordinate2D)coordinate
{
    return __center;
}
//----------------------------------------------------------------------------------
- (MKMapRect)boundingMapRect
{
    return __mapBounds;
}
@end
