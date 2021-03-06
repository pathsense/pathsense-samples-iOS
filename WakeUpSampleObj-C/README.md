# Setup for WakeUp Sample (Obj-C)

1. Obtain a **Pathsense SDK Client ID** and **API Key** from [here](https://pathsense.com/). Click “GET STARTED” and enter your email address.

2. Make sure you are using the latest version of Xcode (10.0+) and targeting iOS 10.0 or higher.

3. Add the PSLocation.framework to your Xcode project (This framework needs to be added to the Embedded Binaries as well).

	![Screenshot1](../frameworks.png?raw=true "")

4. Under the Build Phases tab in your Target, click the + button on the top left and then select New Run Script Phase. Then setup the build phase as follows. Make sure this phase is below the Embed Frameworks phase:

	![Screenshot2](../RunScript.png?raw=true "")

5. In your AppDelegate add the following code to your **application:didFinishLaunchingWithOptions:**

    ```groovy
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		[PSLocation setApiKey:@"your api key here" andClientID:@"your client ID"];
    	return YES;
	}
	```

6. Make sure to include PSLocation framework headers in your AppDelegate.h file:

    ```groovy
	#import <PSLocation/PSLocation.h>
	```

# App Details to Note

1. In **application:didFinishLaunchingWithOptions:** we check the **launchOptions** to see if we are being woken up by the os.  
    
    ```groovy
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
		ViewController *vc = (ViewController *)[[self window] rootViewController];
    	[vc startLocationManager];
    }
	```
2. In the ViewController we have a method **startLocationManager** from this method we call the [PSLocationManager](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/interface_p_s_location_manager.html) method [startMonitoringDeparture](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/interface_p_s_location_manager.html#a3a43a78029a20e19655852f38f1cf4e7)

    ```groovy
    - (void) startLocationManager
    {
        if (_locationManager == nil) {
            ...            
            [_locationManager startMonitoringDeparture];
        }
    }
	```

3. From the method **handleButton:** we set a location to monitor for a departure by calling the the [PSLocationManager](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/interface_p_s_location_manager.html) method [setDepartureCoordinate](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/interface_p_s_location_manager.html#a012162887bc6d223cf5e20bddaa49cbe)

    ```groovy
    - (void)handleButton:(id)sender
    {
        #warning set the location you want to monitor departures for here
        [_locationManager setDepartureCoordinate:CLLocationCoordinate2DMake(33.02280304, -117.28318958)];
    }
	```
4. We use the [PSLocationManagerDelegate](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/protocol_p_s_location_manager_delegate_01-p.html) to watch for when a departure location changes **psLocationManager:didUpdateDepartureCoordinate:** and when a departure takes place **psLocationManager:didDepartCoordinate:**.

    ```groovy
    - (void)psLocationManager:(PSLocationManager *)manager didUpdateDepartureCoordinate:(CLLocationCoordinate2D)coordinate
    {
        // this will be called whenever you call setDepartureCoordinate
    }

    - (void)psLocationManager:(PSLocationManager *)manager didDepartCoordinate:(CLLocationCoordinate2D)coordinate
    {
        // this will be called when a departure is detected -- at this point you need to start getting locations
        // the coordinate passed in will be the coordinate that was passed to setDepartureCoordinate
    }
    ```


