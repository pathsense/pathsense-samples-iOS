//
//  ViewController.h
//  WakeUp Sample
//
//  Created by Paul Schmitt on 11/17/16.
//  Copyright © 2016 PathSense. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

- (void) startLocationManager;

@end

