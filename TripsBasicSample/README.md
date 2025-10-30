# Setup for TripsBasic Sample (Swift)

1. Obtain a **PathSense SDK Client ID** and **API Key** by contacting [PathSense](https://pathsense.com/).  
   > The legacy “GET STARTED” portal is no longer active. SDK credentials are issued privately.

2. Make sure you are using the latest version of **Xcode (16.0 or newer)** and targeting **iOS 14.0 or higher**.

3. Add the **PSLocation.xcframework** (or **PSLocation.framework**) to your Xcode project.  
   This framework must also be added to **Embedded Binaries / Frameworks, Libraries and Embedded Content**, and set to **Embed & Sign**.

   ![Screenshot1](../frameworks.png?raw=true "")

4. Under the **Build Phases** tab in your target, click ➕ and select **New Run Script Phase**.  
   Configure it as shown below, ensuring this phase appears *below* **Embed Frameworks**.

   ![Screenshot2](../RunScript.png?raw=true "")

5. In your **AppDelegate**, add the following code to  
   `application(_:didFinishLaunchingWithOptions:)`:

    ```swift
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PSLocation.setApiKey("YOUR_API_KEY", andClientID: "YOUR_CLIENT_ID")
        return true
    }
    ```

6. Import the PSLocation framework in your **AppDelegate.swift** file:

    ```swift
    import PSLocation
    ```

---

# App Details to Note

1. In **application(_:didFinishLaunchingWithOptions:)**, we configure the [PSLocationManager](http://docs.pathsense.io/ios/html/interface_p_s_location_manager.html):

    ```swift
    locationManager = PSLocationManager()
    locationManager?.setDelegate(self)
    locationManager?.requestAlwaysAuthorization()
    locationManager?.setTripsForcesAppToRemainAwake(true)

    if (launchOptions?.index(forKey: .location)) != nil {
        locationManager?.tripsLaunch(viaOS: application)
    }
    ```

2. In the **LocationManager** delegate function **locationManager(_:didChangeAuthorization:)**, we call **startMonitoringTrips** once authorization is granted:

    ```swift
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            // waiting for user prompt
        } else if status == .restricted || status == .denied {
            print("This application is not authorized to use location services -> \(status)")
            locationManager?.stopMonitoringTrips()
        } else {
            locationManager?.startMonitoringTrips()
        }
    }
    ```

3. We only record **vehicle drives** as trips.  
   The delegate function **psLocationManager(_:willStartTripOf:)** lets us filter trip types before recording:

    ```swift
    func psLocationManager(_ manager: PSLocationManager!, willStartTripOf tripType: PSTripType) -> PSTripType {
        switch tripType {
        case .automotive:
            // record only automotive trips
            return tripType
        default:
            return .unknown
        }
    }
    ```

4. Several other trip-related delegate methods provide trip lifecycle updates.  
   For example:

    ```swift
    func psLocationManager(_ manager: PSLocationManager!, tripStarted trip: PSTrip!) {
        // called when the trip begins
    }

    func psLocationManager(_ manager: PSLocationManager!, tripUpdated trip: PSTrip!) {
        // called each time the trip is updated (a new location is received)
    }

    func psLocationManager(_ manager: PSLocationManager!, tripStopped trip: PSTrip!) {
        // called when the trip ends
    }
    ```

---

**SDK Version:** 1.5.1  **Xcode:** 16  **iOS Target:** 14 or later  
© PathSense Inc. — Updated for SDK 1.5.1 / Xcode 16 / iOS 18
