//
//  ObservationManager.h
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

#import "Observation.h"

#import <PSLocation/PSLocation.h>

extern NSString * const UpdatedOservationsNotification;
extern NSString * const DataBaseInitializedAndReadyNotification;

@class Observation;

@interface ObservationManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, nonatomic) NSArray<NSDate *> *orderedObservationDates;
@property (readonly, nonatomic) PSLocationManager *locationManager;
@property (nonatomic) BOOL dataStoreReady;

+ (ObservationManager *) instance;

- (void)saveContext;
- (Observation *) observationFromId:(NSManagedObjectID *)objectID;
- (Observation *)addObservation;
- (NSArray *) fetchAllObservations;
- (NSArray *) fetchObservationsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSArray *) fetchObservationsOfType:(PSObservationType)type fromLocation:(CLLocation *)location;

- (void) removeObservationaPriorTo:(NSDate *)date;
- (void) requestObservationUpdate;
- (void) locationLaunch:(UIApplication *)application;

@end
