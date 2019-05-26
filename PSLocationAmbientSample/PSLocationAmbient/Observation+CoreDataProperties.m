//
//  Observation+CoreDataProperties.m
//  PSObserver
//
//  Created by Paul Schmitt on 7/14/17.
//  Copyright © 2017 PathSense. All rights reserved.
//
//

#import "Observation+CoreDataProperties.h"

@implementation Observation (CoreDataProperties)

+ (NSFetchRequest<Observation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Observation"];
}

@dynamic cllocation;
@dynamic receivedAtTimestamp;
@dynamic timestamp;
@dynamic type;
@dynamic uploaded;
@dynamic ssidName;

@end
