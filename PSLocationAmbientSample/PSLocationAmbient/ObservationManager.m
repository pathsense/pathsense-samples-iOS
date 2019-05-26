//
//  ObservationManager.m
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <CoreMotion/Coremotion.h>

#import "AppDelegate.h"
#import "ObservationManager.h"
#import "SettingsViewController.h"
#import "UIAlertController+Window.h"

NSString * const UpdatedOservationsNotification = @"UpdatedOservationsNotification";
NSString * const DataBaseInitializedAndReadyNotification = @"DataBaseInitializedAndReadyNotification";

@interface ObservationManager () <PSLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray<NSDate *> *observationDates;

- (void)dataStoreLoaded:(NSManagedObjectContext *)ctx;
- (NSArray *) sortObservationDates;
- (NSArray *) insertOrderedObservationDate:(NSDate *)date;

@end

@implementation ObservationManager

#pragma mark -
//----------------------------------------------------------------------------------
+ (ObservationManager *) instance
{
	static ObservationManager *sMgr = nil;
	if (sMgr == (void *)-1) {
		return nil;
	}
    if (sMgr == nil) {
        sMgr = [ObservationManager new];
        [sMgr managedObjectContext];
    }
    return sMgr;
}
//----------------------------------------------------------------------------------
- (instancetype) init
{
	if (self = [super init]) {
		_dataStoreReady = NO;
        _observationDates = [NSMutableArray array];
  
		_locationManager = [PSLocationManager new];
        [_locationManager setDelegate:self];
        
        [_locationManager requestAlwaysAuthorization];
        [_locationManager setAllowsBackgroundLocationUpdates:YES];

        [_locationManager setMinAllowedSecondsBeforeAmbientLocationWillSleep:[SettingsViewController allowedWakeTime]];
        [_locationManager setIncreaseAmbientLocationFrequencyWhenPossible:[SettingsViewController useIncreaseFrequencyWhenPossible]];
        [_locationManager setDesiredAmbientLocationFrequencyInterval:10];
    }
    return self;
}
//----------------------------------------------------------------------------------
- (void) dealloc
{
}
//----------------------------------------------------------------------------------
- (void) locationLaunch:(UIApplication *)application
{
    [_locationManager setMinAllowedSecondsBeforeAmbientLocationWillSleep:[SettingsViewController allowedWakeTime]];
    [_locationManager setIncreaseAmbientLocationFrequencyWhenPossible:[SettingsViewController useIncreaseFrequencyWhenPossible]];
    [_locationManager setDesiredAmbientLocationFrequencyInterval:10];
    [_locationManager startMonitoringAmbientLocationChanges];
}
//----------------------------------------------------------------------------------
- (void)dataStoreLoaded:(NSManagedObjectContext *)ctx
{
	_dataStoreReady = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:DataBaseInitializedAndReadyNotification object:self];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PSObserver" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
//----------------------------------------------------------------------------------
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @{@"synchronous" : @"NORMAL", @"journal_mode" : @"WAL"}, NSSQLitePragmasOption,
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        NSURL *storeURL = [[AppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"PSObserver.sqlite"];
        NSError *error = nil;
        NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        
        NSPersistentStore *store = [[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        if (store == nil) {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"com.pathsense.psobserver" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if (store) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self dataStoreLoaded:[self managedObjectContext]];
            });
        }
    });
    return _persistentStoreCoordinator;
}
//----------------------------------------------------------------------------------
- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [_managedObjectContext setUndoManager:nil]; // we do not support undo -- this provides a performance benefit
    return _managedObjectContext;
}

//----------------------------------------------------------------------------------
- (void) requestObservationUpdate
{
    NSArray *array = [self fetchAllObservations];
    [_observationDates removeAllObjects];
    
    if ([array count]) {
		for (Observation *observation in array) {
        	[_observationDates addObject:[observation timestamp]];
        }
        _orderedObservationDates = [self sortObservationDates];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdatedOservationsNotification object:self userInfo:@{@"observations" : array}];
	}
}
//----------------------------------------------------------------------------------
- (NSArray *) sortObservationDates
{
    NSArray *result = [_observationDates sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    return result;
}
//----------------------------------------------------------------------------------
- (NSArray *) insertOrderedObservationDate:(NSDate *)date
{
    if (date) {
        NSMutableArray *mArray;
        if (_orderedObservationDates) {
        	mArray = [_orderedObservationDates mutableCopy];
        } else {
            mArray = [NSMutableArray array];
        }
        
        NSUInteger newIndex = [mArray indexOfObject:date inSortedRange:(NSRange){0, [mArray count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        [mArray insertObject:date atIndex:newIndex];
        return [mArray copy];
    
    } else {
        return _orderedObservationDates;
    }
}

#pragma mark - Core Data
#pragma mark -
//----------------------------------------------------------------------------------
- (void)uploadFailed:(NSArray *)array
{
	NSManagedObjectContext *moc = [[array firstObject] managedObjectContext];
    if (moc) {
    	[moc performBlockAndWait:^{
            for (Observation *observation in array) {
                [observation setUploaded:@(NO)];
            }
            NSError *error = nil;
            [moc save:&error];
        }];
    }
}
//----------------------------------------------------------------------------------
- (void)saveContext
{
	if (_persistentStoreCoordinator == nil) {
		return;
	}
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}
//----------------------------------------------------------------------------------
- (Observation *) observationFromId:(NSManagedObjectID *)objectID
{
    Observation *result = nil;
	if (objectID) {
    	NSError *error;
        result = (Observation *)[[self managedObjectContext] existingObjectWithID:objectID error:&error];
        if (error != nil) {
            NSLog(@"%@", [error description]);
        }
    }
    return result;
}
//----------------------------------------------------------------------------------
- (Observation *)addObservation
{
	Observation *result = [NSEntityDescription insertNewObjectForEntityForName:[Observation entityName] inManagedObjectContext:[self managedObjectContext]];
    [result setReceivedAtTimestamp:[NSDate date]];
    return result;
}
//----------------------------------------------------------------------------------
- (NSUInteger) countAllObservations
{
    NSUInteger result;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Observation"];
    @try {
    	NSError *error = nil;
        result = [_managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (error != nil) {
            NSLog(@"%@", [error description]);
        }
    } @catch (NSException *localException) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [localException reason]);
    }
    return result;
}
//----------------------------------------------------------------------------------
- (NSArray *) fetchAllObservations
{
    return [self fetchObservationsFromDate:nil toDate:nil];
}
//----------------------------------------------------------------------------------
- (NSArray *) fetchObservationsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Observation"];
    
    if (fromDate && toDate) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ AND timestamp <= %@", fromDate, toDate];
        [fetchRequest setPredicate:predicate];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:fetchRequest error: &error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    
    return result;
}
//----------------------------------------------------------------------------------
- (NSArray *) fetchObservationsOfType:(PSObservationType)type fromLocation:(CLLocation *)location
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Observation"];
	NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", @(type)];
    [fetchRequest setPredicate:typePredicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:fetchRequest error: &error];
    if (error) {
        NSLog(@"error: %@",error);
    } else {
        NSPredicate *distancePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings) {
            BOOL result = NO;
            CLLocationDistance distance = [(CLLocation *)[evaluatedObject cllocation] distanceFromLocation:location];
            if (distance <= 50) {
                result = YES;
            }
            return result;
        }];
        result = [result filteredArrayUsingPredicate:distancePredicate];
    }
    return result;
}
//----------------------------------------------------------------------------------
- (void) removeObservationaPriorTo:(NSDate *)date
{
	NSDate *fromDate = [NSDate dateWithTimeIntervalSince1970:0];

	NSArray<Observation *> *array = [self fetchObservationsFromDate:fromDate toDate:date];
	
	if ([array count] > 0) {
		NSManagedObjectContext *mObjCtx = [self managedObjectContext];
		for (Observation *observation in array) {
			[mObjCtx deleteObject:observation];
		}
		[self saveContext];
    	[[NSNotificationCenter defaultCenter] postNotificationName:UpdatedOservationsNotification object:self userInfo:@{@"observations" : @[] }];
	}
}


#pragma mark - PSLocationManagerDelegate / PSAmbientLocationDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void)locationManager:(PSLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusNotDetermined) {
        
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Location Autorization", nil) message:NSLocalizedString(@"This application is not authorized to use location services!", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            UIApplication *application = [UIApplication sharedApplication];
			[application openURL:url options:@{} completionHandler:nil];
        }];
        [alertController addAction:action];
        [alertController show];
        
    } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startMonitoringAmbientLocationChanges];
		
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Location Autorization Status", nil) message:NSLocalizedString(@"PSObserver requires kCLAuthorizationStatusAuthorizedAlways to function properly.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            UIApplication *application = [UIApplication sharedApplication];
			[application openURL:url options:@{} completionHandler:nil];
        }];
        [alertController addAction:action];
        [alertController show];
    }
}
//----------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSMutableArray<Observation *> *obs = [NSMutableArray array];
    for (CLLocation *location in locations) {
    	Observation *observation = [self addObservation];
    	[observation setType:@(PSObservationTypeLocationChange)];
    	[observation setCllocation:location];
    	[observation setTimestamp:[location timestamp]];
        [obs addObject:observation];
    }
	[self saveContext];
    
    if ([obs count] == 1) {
        [_observationDates addObject:[[obs firstObject] timestamp]];
        _orderedObservationDates = [self insertOrderedObservationDate:[[obs firstObject] timestamp]];
    } else {
        for (Observation *observation in obs) {
            [_observationDates addObject:[observation timestamp]];
        }
        _orderedObservationDates = [self sortObservationDates];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdatedOservationsNotification object:self userInfo:@{@"observations" : obs }];
}
//----------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alertController show];
}
@end
