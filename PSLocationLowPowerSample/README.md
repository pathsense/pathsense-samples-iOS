# Setup for PSLocation Low Power Sample (Obj-C)

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

1. In **viewDidLoad:** we set up the [PSLocationManager](https://docs.pathsense.io/ios/html/interface_p_s_location_manager.html):

    ```objective-c
    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setPausesLocationUpdatesWhenDeviceIsStationary:YES];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    ```

2. We respond to **psLocationManager:desiredAccuracyForActivity:withConfidence:** and **psLocationManager:distanceFilterForActivity:withConfidence:** — methods unique to the [PSLocationManagerDelegate](https://docs.pathsense.io/ios/html/protocol_p_s_location_manager_delegate-p.html).  
   From these callbacks, we check the detected activity and adjust `desiredAccuracy` and `distanceFilter` accordingly:

    ```objective-c
    - (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager
               desiredAccuracyForActivity:(PSActivityType)activityType
                           withConfidence:(PSActivityConfidence)confidence
    {
        CLLocationAccuracy result;
        
        if (activityType == PSActivityTypeInVehicle || activityType == PSActivityTypeInVehicleStationary) {
            result = kCLLocationAccuracyBestForNavigation;
        
        } else if (activityType == PSActivityTypeOnBicycle || activityType == PSActivityTypeRunning) {
            result = kCLLocationAccuracyBest;

        } else if (activityType == PSActivityTypeWalking || activityType == PSActivityTypeUnknown) {
            result = kCLLocationAccuracyNearestTenMeters;

        } else if (activityType == PSActivityTypeUnknown) {
            if (confidence > PSActivityConfidenceLow) {
                result = [manager desiredAccuracy];
            } else {
                result = kCLLocationAccuracyThreeKilometers;
            }
        
        } else {
            result = kCLLocationAccuracyThreeKilometers;
        }
        return result;
    }

    - (CLLocationDistance)psLocationManager:(PSLocationManager *)manager
              distanceFilterForActivity:(PSActivityType)activityType
                         withConfidence:(PSActivityConfidence)confidence
    {
        CLLocationDistance result;
        
        if (activityType == PSActivityTypeInVehicle) {
            result = 5;
        
        } else if (activityType == PSActivityTypeInVehicleStationary) {
            result = 50;
        
        } else if (activityType == PSActivityTypeOnBicycle || activityType == PSActivityTypeRunning) {
            result = 5;

        } else if (activityType == PSActivityTypeWalking || activityType == PSActivityTypeUnknown) {
            result = 10;

        } else if (activityType == PSActivityTypeUnknown) {
            if (confidence > PSActivityConfidenceLow) {
                result = [manager distanceFilter];
            } else {
                result = CLLocationDistanceMax;
            }
        
        } else {
            result = CLLocationDistanceMax;
        }
        
        return result;
    }
    ```

---

**SDK Version:** 1.5.1  **Xcode:** 16  **iOS Target:** 14 or later  
© PathSense Inc. — Updated for SDK 1.5.1 / Xcode 16 / iOS 18
