//
//  PSTripLocation.h
//  PSLocation
//
//  Created by Paul Schmitt on 11/27/19.
//  Copyright © 2019 PathSense. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class TripLocation;

NS_ASSUME_NONNULL_BEGIN

@interface PSTripLocation : NSObject
    @property (nonatomic) CLLocationCoordinate2D coordinate;
    @property (nonatomic) CLLocationSpeed speed;
    @property (nonatomic) CLLocationDistance altitude;
    @property (nonatomic) CLLocationAccuracy horizontalAccuracy;
    @property (nonatomic) CLLocationAccuracy verticalAccuracy;
    @property (nonatomic) NSTimeInterval timestamp;

- (instancetype) initWithTripLocation:(TripLocation *)tripLocation;
+ (NSArray<PSTripLocation *> *) psTripLocationsFromTripLocations:(NSSet<TripLocation *> *)tripLocations;

@end


NS_ASSUME_NONNULL_END
