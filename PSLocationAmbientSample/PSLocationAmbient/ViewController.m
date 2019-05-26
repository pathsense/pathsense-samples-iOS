//
//  ViewController.m
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <MapKit/MapKit.h>

#import <PSLocation/PSLocation.h>
#import "AppDelegate.h"
#import "MKMapView+ZoomLevel.h"
#import "Observation.h"
#import "ObservationAnnotation.h"
#import "ObservationManager.h"
#import "SettingsViewController.h"
#import "ViewController.h"

@interface ViewController () <ScrubberViewDelegate, UINavigationBarDelegate, SettingsViewControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) NSInteger fromIndex;
@property (nonatomic) NSInteger toIndex;
@property (nonatomic) BOOL mapIsReady;

@end

@implementation ViewController

//----------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[NSLocale currentLocale]];
    [_dateFormatter setDateFormat:@"MM/dd/yyyy – HH:mm"];

	_fromIndex = _toIndex = 0;
    [_fromScrubberView setDelegate:self];
    [[_fromScrubberView rightButton] addTarget:self action:@selector(handleFromRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [[_fromScrubberView leftButton] addTarget:self action:@selector(handleFromLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [[_toScrubberView slider] setValue:1];
    [_toScrubberView setDelegate:self];
    [[_toScrubberView rightButton] addTarget:self action:@selector(handleToRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [[_toScrubberView leftButton] addTarget:self action:@selector(handleToLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [[[_toScrubberView rightButton] imageView] image];
    [[_toScrubberView rightButton] setImage:image forState:UIControlStateNormal];
    
    image = [[[_fromScrubberView rightButton] imageView] image];
    [[_fromScrubberView rightButton] setImage:image forState:UIControlStateNormal];
    
    image = [[[_toScrubberView leftButton] imageView] image];
    [[_toScrubberView leftButton] setImage:image forState:UIControlStateNormal];
    
    image = [[[_fromScrubberView leftButton] imageView] image];
    [[_fromScrubberView leftButton] setImage:image forState:UIControlStateNormal];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdatedOservationsNotification:) name:UpdatedOservationsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataBaseInitializedAndReadyNotification:) name:DataBaseInitializedAndReadyNotification object:nil];
}
//----------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//----------------------------------------------------------------------------------
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect r = [[[self view] safeAreaLayoutGuide] layoutFrame];

    CGRect nr = [_navigationBar frame];
    nr.origin.y = r.origin.y;
    [_navigationBar setFrame:nr];
    
    CGRect mr = [_mapView frame];
    mr.origin.y = nr.origin.y + nr.size.height;
    mr.size.height = [[self view] bounds].size.height - mr.origin.y;
    [_mapView setFrame:mr];
    
    CGRect rr = [_toScrubberView frame];
    rr.origin.y = (r.origin.y + r.size.height) - rr.size.height;
    [_toScrubberView setFrame:rr];
    
    rr = CGRectOffset(rr, 0, -rr.size.height);
    [_fromScrubberView setFrame:rr];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void) handleDataBaseInitializedAndReadyNotification:(NSNotification *)notification
{
	ObservationManager *mgr = [notification object];
    _toIndex = -1;
    [mgr requestObservationUpdate];
}
//----------------------------------------------------------------------------------
- (void) handleUpdatedOservationsNotification:(NSNotification *)notification
{
	ObservationManager *mgr = [notification object];
	NSDictionary *dict = [notification userInfo];
    NSArray *observations = dict[@"observations"];
    [self dropPinsForObservations:observations];
	
    if (_toIndex == -1) {
    	_toIndex = MAX([[mgr orderedObservationDates] count]-1, 0);
    
    } else if (_toIndex == [[mgr orderedObservationDates] count]-2) {
        _toIndex = MAX([[mgr orderedObservationDates] count]-1, 0);

    } else if ([[mgr orderedObservationDates] count]) {
		// we need to readjust the thumb position of the to slider
		double value = (double)(_toIndex+1) / (double)[[mgr orderedObservationDates] count];
  		[[_toScrubberView slider] setValue:value];
    }
	[self updateScrubberLabel];
}
//----------------------------------------------------------------------------------
- (void) handleFromRightButton:(id)sender
{
	ObservationManager *mgr = [ObservationManager instance];
	_fromIndex = MIN(_fromIndex+1, _toIndex);
    [[_fromScrubberView slider] setValue:(float)(_fromIndex+1)/(float)[[mgr orderedObservationDates] count] animated:NO];
    [_fromScrubberView setNeedsLayout];
    [self dropPinsFromIndex:_fromIndex toIndex:_toIndex];
	[self updateScrubberLabel];
}
//----------------------------------------------------------------------------------
- (void) handleFromLeftButton:(id)sender
{
	ObservationManager *mgr = [ObservationManager instance];
	_fromIndex = MAX(_fromIndex-1, 0);
    [[_fromScrubberView slider] setValue:(float)(_fromIndex+1)/(float)[[mgr orderedObservationDates] count] animated:NO];
    [_fromScrubberView setNeedsLayout];
    [self dropPinsFromIndex:_fromIndex toIndex:_toIndex];
	[self updateScrubberLabel];
}
//----------------------------------------------------------------------------------
- (void) handleToRightButton:(id)sender
{
	ObservationManager *mgr = [ObservationManager instance];
	_toIndex = MIN(_toIndex+1, [[mgr orderedObservationDates] count]-1);
    [[_toScrubberView slider] setValue:(float)(_toIndex+1)/(float)[[mgr orderedObservationDates] count] animated:NO];
    [_toScrubberView setNeedsLayout];
    [self dropPinsFromIndex:_fromIndex toIndex:_toIndex];
	[self updateScrubberLabel];
}
//----------------------------------------------------------------------------------
- (void) handleToLeftButton:(id)sender
{
	ObservationManager *mgr = [ObservationManager instance];
	_toIndex = MAX(_toIndex-1, _fromIndex);
    
    [[_toScrubberView slider] setValue:(float)(_toIndex+1)/(float)[[mgr orderedObservationDates] count] animated:NO];
    [_toScrubberView setNeedsLayout];
    [self dropPinsFromIndex:_fromIndex toIndex:_toIndex];
	[self updateScrubberLabel];
}
//----------------------------------------------------------------------------------
- (IBAction)handleSettingsButton:(id)sender
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [settingsViewController setTitle:@"Settings"];
    [settingsViewController setDelegate:self];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}
//----------------------------------------------------------------------------------
- (IBAction)handleLocationButton:(id)sender
{
    ObservationManager *mgr = [ObservationManager instance];
    NSDate *fromDate = [[mgr orderedObservationDates] lastObject];
    NSArray *array = [mgr fetchObservationsFromDate:fromDate toDate:fromDate];
    Observation *observation = [array firstObject];
    if (observation) {
        [_mapView setCenterCoordinate:[(CLLocation *)[observation cllocation] coordinate] animated:YES];
    }
}

#pragma mark -
//----------------------------------------------------------------------------------
- (NSArray *)observationAnnotations
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [ObservationAnnotation class]];
    NSArray *result = [[_mapView annotations] filteredArrayUsingPredicate:predicate];
    return result;
}
//----------------------------------------------------------------------------------
- (void)removeAllObservationPins
{
	NSArray *array = [self observationAnnotations];
    [_mapView removeAnnotations:array];
}
//----------------------------------------------------------------------------------
- (void)removeObservationPinsNotInArray:(NSArray *)inArray
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[inArray count]];
    for (Observation *observation in inArray) {
    	[mArray addObject:[observation objectID]];
    }
    
    NSArray *array = [self observationAnnotations];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!(self.objectID IN %@)", mArray];
	NSArray *foundAnnotations = [array filteredArrayUsingPredicate:predicate];
    [_mapView removeAnnotations:foundAnnotations];
}
//----------------------------------------------------------------------------------
- (void)dropPinsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	ObservationManager *mgr = [ObservationManager instance];
    NSArray *array = [mgr fetchObservationsFromDate:fromDate toDate:toDate];
    [self removeObservationPinsNotInArray:array];
    [self dropPinsForObservations:array];
}
//----------------------------------------------------------------------------------
- (void)dropPinsFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
	ObservationManager *mgr = [ObservationManager instance];
    NSDate *fromDate = [mgr orderedObservationDates][fromIndex];
    NSDate *toDate = [mgr orderedObservationDates][toIndex];
	[self dropPinsFromDate:fromDate toDate:toDate];
}
//----------------------------------------------------------------------------------
- (void)dropPinsForObservations:(NSArray *)inArray
{
	NSArray *observationAnnotations = [self observationAnnotations];
	
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[observationAnnotations count]];
    for (ObservationAnnotation *annotation in observationAnnotations) {
        [mArray addObject:[annotation objectID]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!(self.objectID IN %@)", mArray];
    NSArray *array = [inArray filteredArrayUsingPredicate:predicate];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
	for (Observation *observation in array) {
    	CLLocation *location = (CLLocation *)[observation cllocation];
    	coordinate = [location coordinate];
        
        ObservationAnnotation *annotation = [[ObservationAnnotation alloc] initWithCoordinate:coordinate];
        [annotation setObjectID:[observation objectID]];
        [_mapView addAnnotation:annotation];
	}
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self mapView] setCenterCoordinate:coordinate zoomLevel:18 animated:NO];
    });
}
//----------------------------------------------------------------------------------
- (void)updateScrubberLabel
{
	ObservationManager *mgr = [ObservationManager instance];
	if ([[mgr orderedObservationDates] count] == 0) {
    	return;
    }
    
	NSDate *date = [mgr orderedObservationDates][_fromIndex];

    [[_fromScrubberView label] setText:[_dateFormatter stringFromDate:date]];
    NSString *str = [NSString stringWithFormat:@"%@ of %@", @(_fromIndex + 1), @([[mgr orderedObservationDates] count])];
    [[_fromScrubberView numberOfLabel] setText:str];
    
    date = [mgr orderedObservationDates][_toIndex];
    [[_toScrubberView label] setText:[_dateFormatter stringFromDate:date]];
    str = [NSString stringWithFormat:@"%@ of %@", @(_toIndex + 1), @([[mgr orderedObservationDates] count])];
    [[_toScrubberView numberOfLabel] setText:str];
}

#pragma mark - SettingsViewControllerDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void) settingsViewControllerDidFinish:(SettingsViewController *)settingsViewController
{
    ObservationManager *mgr = [ObservationManager instance];
    [[mgr locationManager] setMinAllowedSecondsBeforeAmbientLocationWillSleep:[SettingsViewController allowedWakeTime]];
    [[mgr locationManager] setIncreaseAmbientLocationFrequencyWhenPossible:[SettingsViewController useIncreaseFrequencyWhenPossible]];
    [[mgr locationManager] setDesiredAmbientLocationFrequencyInterval:5];
	[AppDelegate removeOldObservations];
}

#pragma mark - ScrubberViewDelegate
#pragma mark -

//----------------------------------------------------------------------------------
- (void)scrubberView:(ScrubberView*)scrubberView valueChanged:(float)value
{
	if (scrubberView == _fromScrubberView) {
        ObservationManager *mgr = [ObservationManager instance];
        NSUInteger index = MAX(0, (long)((float)[[mgr orderedObservationDates] count] * value)-1);
        if (index > _toIndex) {
        	index = _toIndex;
    		[[_fromScrubberView slider] setValue:(float)(index+1)/(float)[[mgr orderedObservationDates] count] animated:NO];
            [_fromScrubberView setNeedsLayout];
        }
        if (index != _fromIndex) {
            _fromIndex = index;
            //NSLog(@"from = %@", @(_fromIndex));
            [self dropPinsFromIndex:_fromIndex toIndex:_toIndex];
            [self updateScrubberLabel];
        }
        
    } else if (scrubberView == _toScrubberView) {
        ObservationManager *mgr = [ObservationManager instance];
        NSUInteger index = MAX(0, (long)((float)[[mgr orderedObservationDates] count] * value)-1);
        if (index<_fromIndex) {
        	index = _fromIndex;
    		[[_toScrubberView slider] setValue:(float)(index+1)/(float)[[mgr orderedObservationDates] count] animated:NO];
            [_toScrubberView setNeedsLayout];
        }
        if (index != _toIndex) {
            _toIndex = index;
            //NSLog(@"to = %@", @(_toIndex));
            [self dropPinsFromIndex:_fromIndex toIndex:_toIndex];
            [self updateScrubberLabel];
        }
    }
}

#pragma mark - MKMapViewDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    static BOOL sFirstTime = YES;
    if (sFirstTime) {
    	sFirstTime = NO;
        _mapIsReady = YES;
    	_toIndex = -1;
		[[ObservationManager instance] requestObservationUpdate];
    }
}
//----------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *result = nil;
    if ([annotation isMemberOfClass:[ObservationAnnotation class]] == YES) {
    
        result = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ObservationAnnotationIdentifier"];
        if (result == nil) {
            result = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ObservationAnnotationIdentifier"];
            
        } else {
            //If re-using a view from another annotation, point the view to current annotation.
            [result setAnnotation:annotation];
        }

        ObservationManager *mgr = [ObservationManager instance];
        Observation *observation = [mgr observationFromId:[(ObservationAnnotation *)annotation objectID]];
        
        [(ObservationAnnotation *)annotation setTitle:@"CLLocation"];
        NSTimeInterval timestamp = [[(CLLocation *)[observation cllocation] timestamp] timeIntervalSince1970];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        [(ObservationAnnotation *)annotation setTitle:[_dateFormatter stringFromDate:date]];
        [(ObservationAnnotation *)annotation setSubtitle:[(CLLocation *)[observation cllocation] description]];

        switch ([[observation type] integerValue]) {
            case PSObservationTypeLocationChange:
            	if ([(CLLocation *)[observation cllocation] horizontalAccuracy] >= 500) {
                	[(MKPinAnnotationView *)result setPinTintColor:[UIColor brownColor]];
              	} else {
                	[(MKPinAnnotationView *)result setPinTintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.33]];
                }
                break;
        }
    }
    return result;
}

#pragma mark - UINavigationBarDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (UIBarPosition) positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}
@end
