//
//  DataOverlay.h
//  PSLocationTracker
//
//  Created by Paul Schmitt on 9/22/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface DataOverlay : NSObject <MKOverlay>

@property (atomic, copy) NSArray *locations;

- (instancetype ) initWithLocation:(CLLocation *)location;

- (void) clear;
- (BOOL) containsLocation:(CLLocation *)location;

@end
