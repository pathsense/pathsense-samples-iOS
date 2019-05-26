//
//  ObservationAnnotation.h
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface ObservationAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSManagedObjectID *objectID;

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)inCoordinate;

@end

