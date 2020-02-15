//
//  PSTrip.h
//  PSLocation
//
//  Created by Paul Schmitt on 11/27/19.
//  Copyright © 2019 PathSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTripLocation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PSTripType) {
    PSTripTypeUnknown = 0,
    PSTripTypeAutomotive,
    PSTripTypeCycling,
    PSTripTypeWalking,
    PSTripTypeRunning,
    PSTripTypeStationary // not really a trip but it is a state we can find ourselves in
};

@interface PSTrip : NSObject
    @property (nonatomic, copy, readonly) NSString *udid;
    @property (nonatomic, readonly) PSTripType type;
    @property (nonatomic, copy, readonly) NSDate *startDate;
    @property (nonatomic, copy, readonly) NSDate *endDate;
    @property (nonatomic, readonly) NSArray<PSTripLocation *> *locations;
@end


NS_ASSUME_NONNULL_END
