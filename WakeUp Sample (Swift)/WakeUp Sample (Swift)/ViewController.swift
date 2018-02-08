//
//  ViewController.swift
//  WakeUp Sample (Swift)
//
//  Created by Paul Schmitt on 12/14/16.
//  Copyright © 2016 PathSense. All rights reserved.
//

import UIKit
import MapKit
import PSLocation

class ViewController: UIViewController, UINavigationBarDelegate, PSLocationManagerDelegate, MKMapViewDelegate
{

	var preparingMap = true
	var locationManager : PSLocationManager?
    
	@IBOutlet weak var mapView : MKMapView?
	@IBOutlet weak var navigationBar : UINavigationBar?

    //----------------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        startLocationManager()
        
        let barButtonItem = UIBarButtonItem.init(title: "Set", style: .plain, target: self, action: #selector(handleButton(sender:)))
        navigationBar?.topItem?.leftBarButtonItem = barButtonItem
        barButtonItem.isEnabled = false
    }
    //----------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    {
    	super.viewDidLayoutSubviews()
        
    	var bounds: CGRect
    	if #available(iOS 11.0, *) {
     		bounds = self.view.safeAreaLayoutGuide.layoutFrame
        } else {
        	bounds = self.view.bounds
         	bounds.origin.y = UIApplication.shared.statusBarFrame.size.height
          	bounds.size.height -= bounds.origin.y
        }
		
  		let r = bounds
    	
        var nr = navigationBar?.frame
		nr?.origin.y = r.origin.y
        navigationBar?.frame = nr!
      
        var mr = mapView?.frame
        let y = (nr?.origin.y)! + (nr?.size.height)!
        mr?.size.height = self.view.bounds.size.height - y
        mr?.origin.y = y
        mapView?.frame = mr!
    }

    // MARK: -
    //----------------------------------------------------------------------------------
    func startLocationManager()
    {
    	if (locationManager == nil) {
        	locationManager = PSLocationManager.init()
            locationManager?.setDelegate(self)
            locationManager?.requestAlwaysAuthorization()
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.startMonitoringDeparture()
        }
    }
    //----------------------------------------------------------------------------------
    @objc func handleButton(sender : UIBarButtonItem)
    {
        // FIXME: Set the location you want to monitor departures for here.
    	locationManager?.setDepartureCoordinate(CLLocationCoordinate2DMake(33.02280304, -117.28318958))
    }
    
    // MARK: - UINavigationBarDelegate
    // MARK: -
    //----------------------------------------------------------------------------------
	func position(for bar: UIBarPositioning) -> UIBarPosition
    {
        return .topAttached
    }
    
    // MARK: - PSLocationManagerDelegate
    // MARK: -
    //----------------------------------------------------------------------------------
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
    	if (status == .notDetermined) {
        
        } else if (status == .restricted || status == .denied) {
        	let title = NSLocalizedString("Location Autorization", comment: "")
        	let message = NSLocalizedString("This application is not authorized to use location services!", comment: "")
        	
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            
            let action = UIAlertAction.init(title: NSLocalizedString("Settings...", comment: ""), style: .default, handler: { (UIAlertAction) in
				if let url = URL.init(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in
                	})
                }
            })
            alertController.addAction(action)
            present(alertController, animated: true, completion: {
            })
            
        } else {
        
        }
	}
    //----------------------------------------------------------------------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
		// some of these locations may be stale so you will need to filter them as you want
    	
        for location in locations {
        	let pt = MKPointAnnotation.init()
            pt.title = "Departure"
            pt.coordinate = location.coordinate
            mapView?.addAnnotation(pt)
        }
    }
    //----------------------------------------------------------------------------------
    func psLocationManager(_ manager: PSLocationManager!, didUpdateDepartureCoordinate coordinate: CLLocationCoordinate2D)
    {
		// this will be called whenever you call setDepartureCoordinate

		if preparingMap {
  			return
  		}
  		
    	mapView?.removeAnnotations((mapView?.annotations)!)
        let pt = MKPointAnnotation.init()
        pt.title = "SetLocation"
        pt.coordinate = coordinate
        mapView?.addAnnotation(pt)
        
        let span = MKCoordinateSpanMake(0, (360.0/pow(2.0, 16.0)) * (Double((mapView?.frame.size.width)!)/256.0))
        mapView?.setRegion(MKCoordinateRegion.init(center: coordinate, span: span), animated:true)
	}
    //----------------------------------------------------------------------------------
    func psLocationManager(_ manager: PSLocationManager!, didDepart coordinate: CLLocationCoordinate2D)
    {
		// this will be called when a departure is detected -- at this point you need to start getting locations
    	// the coordinate passed in will be the coordinate that was passed to setDepartureCoordinate
		
        manager.requestLocation()
    }
    //----------------------------------------------------------------------------------
    func psLocationManagerDepartureMonitoringEnded(_ manager: PSLocationManager!)
    {
		// this will be called once the departure coordinate is no longer being monitored
	}

    // MARK: - MKMapViewDelegate
    // MARK: -
    //----------------------------------------------------------------------------------
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView)
    {
		if preparingMap {
        	navigationBar?.topItem?.leftBarButtonItem?.isEnabled = true
        }
        preparingMap = false
	}
    //----------------------------------------------------------------------------------
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
    	var result : MKAnnotationView!
        
		if annotation is MKPointAnnotation {
        	if ((annotation.title)! == "SetLocation") {
            	result = MKPinAnnotationView.init()
                result.tintColor = MKPinAnnotationView.redPinColor()
            } else if ((annotation.title)! == "Departure") {
            	result = MKPinAnnotationView.init()
                result.tintColor = MKPinAnnotationView.greenPinColor()
            }
        }
        
        return result
	}
}

