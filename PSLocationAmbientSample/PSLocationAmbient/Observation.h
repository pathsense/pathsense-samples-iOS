//
//  Observation.h
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Observation+CoreDataClass.h"

typedef NS_ENUM(NSInteger, PSObservationType) {
    PSObservationTypeUnknown = -1,
    PSObservationTypeLocationChange,
};

NS_ASSUME_NONNULL_BEGIN

@interface Observation (PSObserver)

+ (NSString *) entityName;

@end

NS_ASSUME_NONNULL_END


