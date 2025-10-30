# Setup for WakeUp Sample (Obj-C)

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

1. In **application:didFinishLaunchingWithOptions:** we check **launchOptions** to determine whether the app is being woken up by iOS:

    ```objective-c
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        ViewController *vc = (ViewController *)[[self window] rootViewController];
        [vc startLocationManager];
    }
    ```

2. In **ViewController**, the method **startLocationManager** calls  
   [`startMonitoringDeparture`](https://docs.pathsense.io/ios/html/interface_p_s_location_manager.html#a3a43a78029a20e19655852f38f1cf4e7)  
   on the [PSLocationManager](https://docs.pathsense.io/ios/html/interface_p_s_location_manager.html):

    ```objective-c
    - (void)startLocationManager
    {
        if (_locationManager == nil) {
            ...
            [_locationManager startMonitoringDeparture];
        }
    }
    ```

3. From **handleButton:** we set a location to monitor for departure by calling  
   [`setDepartureCoordinate`](https://docs.pathsense.io/ios/html/interface_p_s_location_manager.html#a012162887bc6d223cf5e20bddaa49cbe):

    ```objective-c
    - (void)handleButton:(id)sender
    {
        #warning Set the location you want to monitor departures for here
        [_locationManager setDepartureCoordinate:CLLocationCoordinate2DMake(33.02280304, -117.28318958)];
    }
    ```

4. The [PSLocationManagerDelegate](https://docs.pathsense.io/ios/html/protocol_p_s_location_manager_delegate-p.html) provides callbacks when the departure location changes or a departure occurs:

    ```objective-c
    - (void)psLocationManager:(PSLocationManager *)manager
      didUpdateDepartureCoordinate:(CLLocationCoordinate2D)coordinate
    {
        // Called whenever setDepartureCoordinate is invoked
    }

    - (void)psLocationManager:(PSLocationManager *)manager
             didDepartCoordinate:(CLLocationCoordinate2D)coordinate
    {
        // Called when a departure is detected.
        // The coordinate is the one previously passed to setDepartureCoordinate.
    }
    ```

---

**SDK Version:** 1.5.1  **Xcode:** 16  **iOS Target:** 14 or later  
© PathSense Inc. — Updated for SDK 1.5.1 / Xcode 16 / iOS 18
