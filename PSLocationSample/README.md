# Setup for PSLocation Sample (Obj-C)

1. Obtain a **Pathsense SDK Client ID** and **API Key** from [here](https://pathsense.com/). Click “GET STARTED” and enter your email address.

2. Make sure you are using the latest version of Xcode (8.0+) and targeting iOS 9.0 or higher.

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

5. In **viewDidLoad:** we set up the PSLocationManager 
    
    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setMaximumLatency:20];
    [_locationManager setPausesLocationUpdatesAutomatically:NO];

5. From the PSLocationManagerDelegate we respond to **psLocationManager:desiredAccuracyForActivity:withConfidence:** is unique to the PSLocationManagerDelegate. From here we can check the activity and adjust our desiredAccuracy accordingly. 

	- (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager desiredAccuracyForActivity:(PSActivityType)activityType withConfidence:(PSActivityConfidence)confidence
		
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

5. Note the use of the new accuracy type **kPSLocationAccuracyPathSenseNavigation** added by the PSLocationManager. This will set the PSLocationManager into [TruePath](https://pathsense.com/ios) mode. Also worth noting is this accuracy is only engaged if we detect driving. 
    
