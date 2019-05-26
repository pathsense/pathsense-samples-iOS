//
//  ViewController.h
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ScrubberView.h"

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet ScrubberView *fromScrubberView;
@property (nonatomic, strong) IBOutlet ScrubberView *toScrubberView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

- (void)removeAllObservationPins;
- (void)dropPinsForObservations:(NSArray *)array;
- (void)dropPinsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)dropPinsFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (IBAction)handleSettingsButton:(id)sender;
- (NSArray *)observationAnnotations;

@end

