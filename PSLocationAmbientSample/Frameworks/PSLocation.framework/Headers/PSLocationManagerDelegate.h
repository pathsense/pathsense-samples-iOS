//
//  PSLocationManagerDelegate.h
//
//  Copyright (c) 2015-present PathSense. All rights reserved.
//

@class PSLocationManager;

/*!
	@abstract Delegate for PSLocationManager.
 
 */
@protocol PSLocationManagerDelegate <CLLocationManagerDelegate>

@optional

/*!
	@abstract Invoked when a PSActivityType and/or a PSActivityConfidence level has changed. Return the CLLocationAccuracy
	desired for this activity and or confidence.
 
 	@param manager the PSLocationManager.
 	@param activityType the PSActivityType.
 	@param confidence the PSActivityConfidence.
 	@return the desired location accuarcy for the given activity (including kPSLocationAccuracyPathSenseNavigation).
 */
- (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager
    desiredAccuracyForActivity:(PSActivityType)activityType
    withConfidence:(PSActivityConfidence)confidence;

/*!
	@abstract Invoked when a PSActivityType and/or a PSActivityConfidence level has changed. Return the CLLocationDistance
	for this activity and or confidence.
 
 	@param manager the PSLocationManager.
 	@param activityType the PSActivityType.
 	@param confidence the PSActivityConfidence.
 
 	@return the desired location distance for the given activity.
 */
- (CLLocationDistance)psLocationManager:(PSLocationManager *)manager
    distanceFilterForActivity:(PSActivityType)activityType
	withConfidence:(PSActivityConfidence)confidence;

/*!
	@abstract Invoked when departure has started.
 
 	@param manager the PSLocationManager.
 	@param visitDictionary a dictionary contain visit info (similar) to CLVisit.
    	Keys are:
            PSVisitArrivalDateKey
            PSVisitDepartureDateKey
            PSVisitHorizontalAccuracyKey
            PSVisitLatitudeKey
            PSVisitLongitudeKey
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didPSVisit:(NSDictionary *)visitDictionary;

/*!
	@abstract Invoked when departure has started.
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didStartMonitoringDepartureCoordinate:(CLLocationCoordinate2D)coordinate;

/*!
	@abstract Invoked when a new coordinate is set for the departure service to monitor.
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didUpdateDepartureCoordinate:(CLLocationCoordinate2D)coordinate;

/*!
	@abstract Invoked when departure has been observed. 
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didDepartCoordinate:(CLLocationCoordinate2D)coordinate  __attribute__ ((deprecated("Use 'psLocationManager:didDepartCoordinate:location:' instead.")));

/*!
	@abstract Invoked when departure has been observed. 
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 	@param location the location at the time of departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didDepartCoordinate:(CLLocationCoordinate2D)coordinate
    atLocation:(CLLocation *)location;

/*!
	@abstract Invoked when the departure service is no longer monitoring a coordinate for departure.
 
 	@param manager the PSLocationManager.
 */
- (void)psLocationManagerDepartureMonitoringEnded:(PSLocationManager *)manager;


/*!
    @abstract Invoked once the Trips dtabase is loaded and trips are ready to be recorded and/or fetched.
 
     @param manager the PSLocationManager.
 */
- (void)psLocationManagerTripsDidLoad:(PSLocationManager *)manager;

/*!
    @abstract Called prior to Trip Validation -- this process could be slow if you maintaining a history of trips -- starting a indetriminate progress indicator here if needed
 
     @param manager the PSLocationManager.
 */
- (void)psLocationManagerWillValidateTrips:(PSLocationManager *)manager;

/*!
    @abstract Called after to Trip Validation and just prior to psLocationManagerTripsDidLoad --  stop any (trips related) progress indicators here

     @param manager the PSLocationManager.
 */
- (void)psLocationManagerDidValidateTrips:(PSLocationManager *)manager;

/*!
    @abstract Called after to Trip Validation and just prior to psLocationManagerTripsDidLoad --  stop any (trips related) progress indicators here

     @param manager the PSLocationManager.
     @param triptype the PSLocationManager.
     @return the verified PSTripType.
 */
- (PSTripType)psLocationManager:(PSLocationManager *)manager willStartTripOfType:(PSTripType)triptype;

/*!
    @abstract Called when a trip starts

     @param manager the PSLocationManager.
     @param trip the PSTrip.
 */
- (void)psLocationManager:(PSLocationManager *)manager tripStarted:(PSTrip *)trip;

/*!
    @abstract Called when a trip obtains a new PSTripLocation

     @param manager the PSLocationManager.
     @param trip the PSTrip.
     @param location the PSTripLocation.
 */
- (void)psLocationManager:(PSLocationManager *)manager trip:(PSTrip *)trip recievedLocation:(PSTripLocation *)location;

/*!
    @abstract Called when a trip stops

     @param manager the PSLocationManager.
     @param trip the PSTrip.
 */
- (void)psLocationManager:(PSLocationManager *)manager tripStopped:(PSTrip *)trip;

/*!
    @abstract Called when a trip is updated

     @param manager the PSLocationManager.
     @param trip the PSTrip.
 */
- (void)psLocationManager:(PSLocationManager *)manager tripUpdated:(PSTrip *)trip;

/*!
    @abstract Called when a trip will be removed

     @param manager the PSLocationManager.
     @param trip the PSTrip.
 */
- (void)psLocationManager:(PSLocationManager *)manager tripWillBeRemoved:(PSTrip *)trip;

/*!
    @abstract Called after a trip was removed

     @param manager the PSLocationManager.
     @param tripUID the udid of the removed trip .
 */
- (void)psLocationManager:(PSLocationManager *)manager tripWasRemoved:(NSString *)tripUID;

@end
