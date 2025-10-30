# Setup for PSLocation Sample (Obj-C)

1. Obtain a **PathSense SDK Client ID** and **API Key** by contacting [PathSense](https://pathsense.com/).  
   > The legacy “GET STARTED” portal is no longer active. SDK credentials are issued privately.

2. Make sure you are using the latest version of **Xcode (16.0 or newer)** and targeting **iOS 14.0 or higher**.

3. Add the **PSLocation.xcframework** (or **PSLocation.framework**) to your Xcode project.  
   This framework must also be added to **Embedded Binaries / Frameworks, Libraries and Embedded Content** and set to **Embed & Sign**.

   ![Screenshot1](../frameworks.png?raw=true "")

4. Under the **Build Phases** tab in your target, click ➕ and select **New Run Script Phase**.  
   Configure it as shown below, ensuring this phase appears *below* **Embed Frameworks**.

   ![Screenshot2](../RunScript.png?raw=true "")

5. In your **AppDelegate**, add the following code to  
   `application:didFinishLaunchingWithOptions:`:

    ```objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        [PSLocation setApiKey:@"YOUR_API_KEY" andClientID:@"YOUR_CLIENT_ID"];
        return YES;
    }
    ```

6. Import the PSLocation framework headers in your **AppDelegate.h** file:

    ```objective-c
    #import <PSLocation/PSLocation.h>
    ```

---

# App Details to Note

1. In **viewDidLoad:** we set up the [PSLocationManager](http://docs.pathsense.io/ios/html/interface_p_s_location_manager.html):

    ```objective-c
    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setMaximumLatency:20];
    [_locationManager setPausesLocationUpdatesAutomatically:NO];
    ```

2. We respond to **psLocationManager:desiredAccuracyForActivity:withConfidence:** — a method unique to the [PSLocationManagerDelegate](http://docs.pathsense.io/ios/html/protocol_p_s_location_manager_delegate-p.html).  
   From here we check the detected activity and adjust `desiredAccuracy` accordingly:

    ```objective-c
    - (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager
               desiredAccuracyForActivity:(PSActivityType)activityType
                           withConfidence:(PSActivityConfidence)confidence
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
    ```

3. Note the use of the accuracy type **kPSLocationAccuracyPathSenseNavigation**, introduced by `PSLocationManager`.  
   This enables **TruePath mode**, providing enhanced map-matching accuracy while driving.  
   > The accuracy automatically switches to TruePath mode only when the SDK detects automotive activity.

---

**SDK Version:** 1.5.1  **Xcode:** 16  **iOS Target:** 14 or later  
© PathSense Inc. — Updated for SDK 1.5.1 / Xcode 16 / iOS 18
