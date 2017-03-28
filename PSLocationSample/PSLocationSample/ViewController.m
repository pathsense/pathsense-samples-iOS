//
//  ViewController.m
//  PSLocationSample
//
//  Created by Paul Schmitt on 10/9/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <PSLocation/PSlocation.h>
#import <UIKit/UIKit.h>

#import "DataOverlay.h"
#import "DataOverlayRenderer.h"
#import "MKMapView+ZoomLevel.h"
#import "PSMapView.h"
#import "UserLocationAnnotation.h"
#import "UserLocationAnnotationView.h"
#import "ViewController.h"

#define DEGREES_TO_RADIANS(__ANGLE__)		((__ANGLE__) / 180.0 * M_PI)

@interface ViewController () <PSLocationManagerDelegate>

@property (nonatomic, readwrite) IBOutlet PSMapView *mapView;
@property (nonatomic, readwrite) UserLocationAnnotation *userLocationAnnotation;
@property (nonatomic, strong) DataOverlay *dataOverlay;
@property (nonatomic, readonly) PSLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;

- (IBAction)handleLocationButton:(id)sender;
- (void)updateUserLocation:(CLLocation *)location;
- (void)animateUserLocation:(CLLocation *)location;

@end

@implementation ViewController

//----------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locations = [NSMutableArray array];

    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setMaximumLatency:20];
    [_locationManager setPausesLocationUpdatesAutomatically:NO];
    
	if ([CMMotionActivityManager isActivityAvailable]) {
    	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    } else {
    	[_locationManager setDesiredAccuracy:kPSLocationAccuracyPathSenseNavigation];
    }
    
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS 8 or later
        [_locationManager requestAlwaysAuthorization];
    }
    
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {  // iOS 9 or later
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }

    _userLocationAnnotation = [UserLocationAnnotation new];
    [_mapView addAnnotation:_userLocationAnnotation];
}
//----------------------------------------------------------------------------------
- (BOOL)prefersStatusBarHidden
{
	return YES;
}
//----------------------------------------------------------------------------------
- (IBAction)handleLocationButton:(id)sender
{
	[_mapView setUserAdjusted:NO];
    [_mapView setCenterCoordinate:[_userLocationAnnotation coordinate] animated:YES];
}
//----------------------------------------------------------------------------------
- (void) trimLocationHistory
{
    NSTimeInterval timeCutoff = [[(CLLocation *)[_locations lastObject] timestamp] timeIntervalSince1970] - 600.0;
    if (timeCutoff < 0) {
    	return;
    }
    
	NSMutableArray *mArray = [NSMutableArray array];
    for (CLLocation *location in _locations) {
    	if ([[location timestamp] timeIntervalSince1970] >= timeCutoff) {
        	[mArray addObject:location];
        }
    }
    _locations = [NSMutableArray arrayWithArray:mArray];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void)updateUserLocation:(CLLocation *)location
{
    static dispatch_once_t onceToken;
    
    if (location == nil) {
    	return;
    }
    
    dispatch_once(&onceToken, ^{
        [_mapView setCenterCoordinate:[location coordinate] zoomLevel:18 animated:NO];
    });
    
	[self animateUserLocation:location];

	if ([_mapView userAdjusted] == NO) {
        [_mapView setCenterCoordinate:[location coordinate] animated:YES];
    }
}
//----------------------------------------------------------------------------------
- (void)animateUserLocation:(CLLocation *)location
{
	UIView *view = [_mapView viewForAnnotation:_userLocationAnnotation];
    [_mapView bringSubviewToFront:view];
    CLLocationDirection course = [location course];
    [UIView animateWithDuration:.1
        animations:^{
            if (course!=-1) {
                MKMapCamera *camera = [_mapView camera];
                [view setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(course-camera.heading))];
            }
            [_userLocationAnnotation setCoordinate:[location coordinate]];
        } completion:^(BOOL finished) { }
    ];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void) willEnterForeground
{
	if (_dataOverlay) {
        @synchronized(self) {
            [_dataOverlay setConfirmedLocations:_locations];
        }
        [[_mapView rendererForOverlay:_dataOverlay] setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *result = nil;
    if ([annotation isMemberOfClass:[UserLocationAnnotation class]] == YES) {
        result = [mapView dequeueReusableAnnotationViewWithIdentifier:@"UserLocationAnnotationView"];
    	if (result == nil) {
    		result = [[UserLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UserLocationAnnotationView"];
        }
    }
    return  result;
}
//----------------------------------------------------------------------------------
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayRenderer *result = nil;
    if ([overlay isMemberOfClass:[DataOverlay class]] == YES) {
    	result = [[DataOverlayRenderer alloc] initWithOverlay:overlay];
    }
    return result;
}

#pragma mark -
#pragma mark PSLocationManagerDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusNotDetermined) {
        
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        NSString *title = NSLocalizedString(@"Location Authorization", nil);
        NSString *message = NSLocalizedString(@"This application is not authorized to use location services!", nil);

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];

        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:url options:@{} completionHandler:nil];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [_locationManager startUpdatingLocation];
    }
}
//----------------------------------------------------------------------------------
- (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager desiredAccuracyForActivity:(PSActivityType)activityType withConfidence:(PSActivityConfidence)confidence
{
	CLLocationAccuracy result = [manager desiredAccuracy];
	if (activityType == PSActivityTypeInVehicle || activityType == PSActivityTypeInVehicleStationary) {
    	if (result != kPSLocationAccuracyPathSenseNavigation) {
        	result = kPSLocationAccuracyPathSenseNavigation;
        }
    
    } else {
    	if (result != kCLLocationAccuracyBest) {
        	result = kCLLocationAccuracyBest;
        }
    }
    return result;
}
//----------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self trimLocationHistory];

    for (CLLocation *location in locations) {
        [_locations insertObject:location atIndex:0];
    }
    
    if (_dataOverlay == nil) {
    	_dataOverlay = [[DataOverlay alloc] initWithLocation:[locations lastObject]];
        [_mapView addOverlay:_dataOverlay];
		@synchronized(self) {
    		[_dataOverlay setConfirmedLocations:_locations];
    	}
        
    } else {
    	if ([_dataOverlay containsLocation:[locations lastObject]] == NO) {
        	[_mapView removeOverlay:_dataOverlay];
    		_dataOverlay = [[DataOverlay alloc] initWithLocation:[locations lastObject]];
        	[_mapView addOverlay:_dataOverlay];
        } else {
    		[[_mapView rendererForOverlay:_dataOverlay] setNeedsDisplay];
        }
		@synchronized(self) {
    		[_dataOverlay setConfirmedLocations:_locations];
    	}
    }
    
	[self updateUserLocation:[locations lastObject]];
}
@end
