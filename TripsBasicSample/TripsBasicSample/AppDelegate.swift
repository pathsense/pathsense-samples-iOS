//
//  AppDelegate.swift
//  TripsBasicSample
//
//  Copyright © 2020 PathSense. All rights reserved.
//

import UIKit
import PSLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PSLocationManagerDelegate {


    var window: UIWindow?
    var locationManager: PSLocationManager? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

//        #warning("Add your api key & client ID here")
        PSLocation.setApiKey("your api key here", andClientID: "your client ID")
        
        locationManager = PSLocationManager()
        locationManager?.setDelegate(self)
        locationManager?.requestAlwaysAuthorization()
        locationManager?.setTripsForcesAppToRemainAwake(true)

        if (launchOptions?.index(forKey:.location)) != nil {
            locationManager?.tripsLaunch(viaOS: application)
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .notDetermined {
        
        } else if status == .restricted || status == .denied {
            print("This application is not authorized to use location services -> \(status)")
            locationManager?.stopMonitoringTrips()

        } else {
            locationManager?.startMonitoringTrips()
        }
    }
                           
    func psLocationManager(_ manager: PSLocationManager!, willStartTripOf triptype: PSTripType) -> PSTripType {
        
        switch triptype {
            
            case .automotive:
                // only record automotive trips
                return triptype

            default:
                return .unknown
        }
    }
    
    func psLocationManager(_ manager: PSLocationManager!, tripStarted trip: PSTrip!) {
        // called when the trip begins
    }
    
    func psLocationManager(_ manager: PSLocationManager!, tripUpdated trip: PSTrip!) {
        // called each time the trip is updated (a new location is recieved)
    }

    func psLocationManager(_ manager: PSLocationManager!, tripStopped trip: PSTrip!) {
        // called when the trip ends
    }
}

