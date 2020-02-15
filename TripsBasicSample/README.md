# Setup for TripsBasic Sample

1. Obtain a **Pathsense SDK Client ID** and **API Key** from [here](https://pathsense.com/). Click “GET STARTED” and enter your email address.

2. Make sure you are using the latest version of Xcode (11.0+) and targeting iOS 12.0 or higher.

3. Add the PSLocation.framework to your Xcode project (This framework needs to be added to the Embedded Binaries as well).

	![Screenshot1](../frameworks.png?raw=true "")

4. Under the Build Phases tab in your Target, click the + button on the top left and then select New Run Script Phase. Then setup the build phase as follows. Make sure this phase is below the Embed Frameworks phase:

	![Screenshot2](../RunScript.png?raw=true "")

5. In your AppDelegate add the following code to your **application(_:didFinishLaunchingWithOptions:)**

    ```groovy
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        PSLocation.setApiKey("your api key here", andClientID: "your client ID")
        return true
    }
	```
6. Make sure to include PSLocation framework in your AppDelegate file:

    ```groovy
	import PSLocation
	```

# App Details to Note

1. In **application(_:didFinishLaunchingWithOptions:)** we configure the **PSLocationManager**.  
    
    ```groovy
    locationManager = PSLocationManager()
    locationManager?.setDelegate(self)
    locationManager?.requestAlwaysAuthorization()
    locationManager?.setTripsForcesAppToRemainAwake(true)

    if (launchOptions?.index(forKey:.location)) != nil {
        locationManager?.tripsLaunch(viaOS: application)
    }
    ```

2. In the **LocationManager** delegate function **locationManager:didChangeAuthorization** is where we call **startMonitoringTrips**

    ```groovy
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .notDetermined {
        
        } else if status == .restricted || status == .denied {
            print("This application is not authorized to use location services -> \(status)")
            locationManager?.stopMonitoringTrips()

        } else {
            locationManager?.startMonitoringTrips()
        }
    }
	```

3. We only want to record vehicle drives as a trip so we provide the delegate function  **psLocationManager:willStartTripOf:** this is where we can filter out the trips we do not want to record.

    ```groovy
    func psLocationManager(_ manager: PSLocationManager!, willStartTripOf triptype: PSTripType) -> PSTripType {
        
        switch triptype {
            
            case .automotive:
                // only record automotive trips
                return triptype

            default:
                return .unknown
        }
    }
    ```

4. Final there are a number of Trips related delegate functions here is an example of three that should prove to be hand a you work through your own app that utilizes the trips API.

    ```groovy
    func psLocationManager(_ manager: PSLocationManager!, tripStarted trip: PSTrip!) {
        // called when the trip begins
    }
    
    func psLocationManager(_ manager: PSLocationManager!, tripUpdated trip: PSTrip!) {
        // called each time the trip is updated (a new location is recieved)
    }

    func psLocationManager(_ manager: PSLocationManager!, tripStopped trip: PSTrip!) {
        // called when the trip ends
    }
    ```
