# Setup for PSLocation Ambient Sample (Obj-C)

1. Obtain a **Pathsense SDK Client ID** and **API Key** from [here](https://pathsense.com/). Click “GET STARTED” and enter your email address.

2. Make sure you are using the latest version of Xcode (10.0+) and targeting iOS 11.0 or higher.

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

    1. In **ObservationManager:init** we set up the [PSLocationManager](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/interface_p_s_location_manager.html) 
    
    ```groovy
    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    
    [_locationManager requestAlwaysAuthorization];
    [_locationManager setAllowsBackgroundLocationUpdates:YES];

    [_locationManager setMinAllowedSecondsBeforeAmbientLocationWillSleep:[SettingsViewController allowedWakeTime]];
    [_locationManager setIncreaseAmbientLocationFrequencyWhenPossible:[SettingsViewController useIncreaseFrequencyWhenPossible]];
    [_locationManager setDesiredAmbientLocationFrequencyInterval:10];
```
    
    2. Even though the **PSLocationManager** is set up we do not start monitoring locations until we know we have obtained the correct user permissions.

```groovy
- (void)locationManager:(PSLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        
        ...
        
    } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startMonitoringAmbientLocationChanges];
        
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        ...
    
    }
}

```
3. The delegate method **psLocationManager:didUpdateLocations:** will be the callback method to recieve the location updates.

4. Also in AppDelegate delegate method **application:didFinishLaunchingWithOptions:** the launchOptions are checked to see if we launched because of a location event **UIApplicationLaunchOptionsLocationKey**. If we were then wemake sure we start monitoring locations immeadiatly (see **ObservationManager:locationLaunch**).
```groovy
    ObservationManager *manager = [ObservationManager instance];
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        //Code to handle the location update
        [manager locationLaunch:application];
    }
```
