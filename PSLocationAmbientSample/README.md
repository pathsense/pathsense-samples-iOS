# Setup for PSLocation Ambient Sample (Obj-C)

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

1. In **ObservationManager:init**, we set up the [PSLocationManager](http://docs.pathsense.io/ios/html/interface_p_s_location_manager.html):

    ```objective-c
    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    
    [_locationManager requestAlwaysAuthorization];
    [_locationManager setAllowsBackgroundLocationUpdates:YES];

    [_locationManager setMinAllowedSecondsBeforeAmbientLocationWillSleep:[SettingsViewController allowedWakeTime]];
    [_locationManager setIncreaseAmbientLocationFrequencyWhenPossible:[SettingsViewController useIncreaseFrequencyWhenPossible]];
    [_locationManager setDesiredAmbientLocationFrequencyInterval:10];
    ```

2. Even though the **PSLocationManager** is initialized, we don’t start monitoring locations until proper user permissions are granted:

    ```objective-c
    - (void)locationManager:(PSLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
    {
        if (status == kCLAuthorizationStatusNotDetermined) {
            // waiting for user prompt
        } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            // permissions denied
        } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
            [manager startMonitoringAmbientLocationChanges];
        } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            // limited authorization
        }
    }
    ```

3. The delegate method **psLocationManager:didUpdateLocations:** is the callback that receives location updates.

4. In **application:didFinishLaunchingWithOptions:**, check `launchOptions` to see if the app launched due to a background location event (`UIApplicationLaunchOptionsLocationKey`).  
   If so, start monitoring immediately (see `ObservationManager:locationLaunch`):

    ```objective-c
    ObservationManager *manager = [ObservationManager instance];
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        // Handle relaunch due to location update
        [manager locationLaunch:application];
    }
    ```

---

**SDK Version:** 1.5.1  **Xcode:** 16  **iOS Target:** 14+  
© PathSense Inc. — Updated for SDK 1.5.1 / Xcode 16 / iOS 18
