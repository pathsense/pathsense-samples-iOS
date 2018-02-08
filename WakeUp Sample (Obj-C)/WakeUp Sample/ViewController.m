//
//  ViewController.m
//  WakeUp Sample
//
//  Created by Paul Schmitt on 11/17/16.
//  Copyright © 2016 PathSense. All rights reserved.
//

#import <PSLocation/PSLocation.h>

#import "ViewController.h"

@interface ViewController () <UINavigationBarDelegate, PSLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic) BOOL preparingMap;
@property (nonatomic, readonly) PSLocationManager *locationManager;

- (void)handleButton:(id)sender;

@end

@implementation ViewController
//----------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	_preparingMap = YES;

	[self startLocationManager];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(handleButton:)];
    [[_navigationBar topItem] setLeftBarButtonItem:barButtonItem animated:YES];
    [barButtonItem setEnabled:NO];
}
//----------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds;
    if (@available(iOS 11.0, *)) {
        bounds = [[[self view] safeAreaLayoutGuide] layoutFrame];
    } else {
        bounds = [[self view] bounds];
        bounds.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
        bounds.size.height -= bounds.origin.y;
    }
    CGRect r = bounds;

    CGRect nr = [_navigationBar frame];
    nr.origin.y = r.origin.y;
    [_navigationBar setFrame:nr];
    
    CGRect mr = [_mapView frame];
    mr.origin.y = nr.origin.y + nr.size.height;
    mr.size.height = [[self view] bounds].size.height - mr.origin.y;
    [_mapView setFrame:mr];
}
//----------------------------------------------------------------------------------
- (void)handleButton:(id)sender
{
	#warning set the location you want to monitor departures for here
    [_locationManager setDepartureCoordinate:CLLocationCoordinate2DMake(33.02280304, -117.28318958)];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void) startLocationManager
{
  	if (_locationManager == nil) {
    	_locationManager = [PSLocationManager new];
        [_locationManager setDelegate:self];
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS 8 or later
            [_locationManager requestAlwaysAuthorization];
        }
        
        if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {  // iOS 9 or later
             [_locationManager setAllowsBackgroundLocationUpdates:YES];
        }
        
        [_locationManager startMonitoringDeparture];
    }
}

#pragma mark - UINavigationBarDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	return UIBarPositionTopAttached;
}

#pragma mark - PSLocationManagerDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void)locationManager:(PSLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusNotDetermined) {
    
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
    	NSString *title = NSLocalizedString(@"Location Autorization", nil);
    	NSString *message = NSLocalizedString(@"This application is not authorized to use location services!", nil);

    	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];

    	UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
			[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
    	}];
    	[alertController addAction:action];
    	[self presentViewController:alertController animated:YES completion:^{
        }];
        
    } else {
    }
}
//----------------------------------------------------------------------------------
-(void)locationManager:(PSLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // some of these locations may be stale so you will need to filter them as you want
    
    for (CLLocation *location in locations) {
        MKPointAnnotation *pt = [MKPointAnnotation new];
        [pt setTitle:@"Departure"];
        [pt setCoordinate:[location coordinate]];
        [_mapView addAnnotation:pt]; // this does not persist between runs of the app
        [_mapView setCenterCoordinate:[location coordinate]]; // this does not persist between runs of the app
    }
}
//----------------------------------------------------------------------------------
- (void)psLocationManager:(PSLocationManager *)manager didUpdateDepartureCoordinate:(CLLocationCoordinate2D)coordinate
{
	// this will be called whenever you call setDepartureCoordinate
    
    if (_preparingMap) {
    	return;
    }
    
    [_mapView removeAnnotations:[_mapView annotations]];
    MKPointAnnotation *pt = [MKPointAnnotation new];
    [pt setTitle:@"SetLocation"];
    [pt setCoordinate:coordinate];
    [_mapView addAnnotation:pt]; // this does not persist between runs of the app

    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, 16)*[_mapView frame].size.width/256);
    [_mapView setRegion:MKCoordinateRegionMake(coordinate, span) animated:YES];
}
//----------------------------------------------------------------------------------
- (void)psLocationManager:(PSLocationManager *)manager didDepartCoordinate:(CLLocationCoordinate2D)coordinate
{
    // this will be called when a departure is detected -- at this point you need to start getting locations
    // the coordinate passed in will be the coordinate that was passed to setDepartureCoordinate
	
    [manager requestLocation];
}
//----------------------------------------------------------------------------------
- (void)psLocationManagerDepartureMonitoringEnded:(PSLocationManager *)manager
{
	// this will be called once the departure coordinate is no longer being monitored
}

#pragma mark - MKMapViewDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (_preparingMap) {
    	[[[_navigationBar topItem] leftBarButtonItem] setEnabled:YES];
    }
    _preparingMap = NO;
}
//----------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *result = nil;
    if ([annotation isMemberOfClass:[MKPointAnnotation class]] == YES) {
    	if ([[annotation title] isEqualToString:@"SetLocation"]) {
        	result = [[MKPinAnnotationView alloc] init];
            [(MKPinAnnotationView *)result setPinTintColor:[MKPinAnnotationView redPinColor]];

        } else if ([[annotation title] isEqualToString:@"Departure"]) {
        	result = [[MKPinAnnotationView alloc] init];
            [(MKPinAnnotationView *)result setPinTintColor:[MKPinAnnotationView greenPinColor]];
        }
    }
    return  result;
}

@end
