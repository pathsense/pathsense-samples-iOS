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
	private var preparingMap = true
	private var locationManager : PSLocationManager? = nil
    
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
    
    // MARK: -
    //----------------------------------------------------------------------------------
    func startLocationManager()
    {
        guard self.locationManager == nil else {
            return
        }
        let locationManager = PSLocationManager()
        locationManager.setDelegate(self)
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringDeparture()
        self.locationManager = locationManager
    }
    //----------------------------------------------------------------------------------
	@objc func handleButton(sender : UIBarButtonItem)
    {
    	#warning("Set the location you want to monitor departures for here")
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
    	if status == .notDetermined {
        
        } else if status == .restricted || status == .denied {
        	
            let alertController = UIAlertController(title: "Location Autorization", message: "This application is not authorized to use location services!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            let action = UIAlertAction(title: "Settings...", style: .default, handler: { (UIAlertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            
        } else {
        
        }
	}
    //----------------------------------------------------------------------------------
    func psLocationManager(_ manager: PSLocationManager!, didUpdateDepartureCoordinate coordinate: CLLocationCoordinate2D)
    {
		// this will be called whenever you call setDepartureCoordinate
		
		guard let mapView = mapView else {
            return
        }

    	mapView.removeAnnotations(mapView.annotations)
        let pt = MKPointAnnotation.init()
        pt.title = "SetLocation"
        pt.coordinate = coordinate
        mapView.addAnnotation(pt)
        
        let span = MKCoordinateSpan.init(latitudeDelta: 0, longitudeDelta: (360.0/pow(2.0, 16.0)) * (Double(mapView.frame.size.width)/256.0))
        mapView.setRegion(MKCoordinateRegion.init(center: coordinate, span: span), animated:true)
	}
    //----------------------------------------------------------------------------------
    func psLocationManager(_ manager: PSLocationManager!, didDepart coordinate: CLLocationCoordinate2D, at location: CLLocation!)
    {
		let pt = MKPointAnnotation.init()
		pt.title = "Departure"
		pt.coordinate = location.coordinate
		mapView?.addAnnotation(pt)
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
    	guard preparingMap else {
            return
        }
		
		navigationBar?.topItem?.leftBarButtonItem?.isEnabled = true
        preparingMap = false
	}
    //----------------------------------------------------------------------------------
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
    	var result : MKAnnotationView? = nil
        
        guard let annotation = annotation as? MKPointAnnotation else {
            return result
        }
        
        if annotation.title == "SetLocation" {
            result = MKPinAnnotationView()
            result?.tintColor = MKPinAnnotationView.redPinColor()
        } else if annotation.title == "Departure" {
            result = MKPinAnnotationView()
            result?.tintColor = MKPinAnnotationView.greenPinColor()
        }

        return result
	}
}
