# Setup for PSLocation Low Power Sample (Obj-C)

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

1. In **viewDidLoad:** we set up the [PSLocationManager](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/interface_p_s_location_manager.html) 
    
    ```groovy
    _locationManager = [PSLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setPausesLocationUpdatesWhenDeviceIsStationary:YES];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
```
    
2. We respond to **psLocationManager:desiredAccuracyForActivity:withConfidence:** and **cationManager:distanceFilterForActivity:withConfidence:** this is unique to the [PSLocationManagerDelegate](https://developer.pathsense.com/sites/pathsensedeveloperportal.dd/files/documentation/ios/sdk/location/1.2/protocol_p_s_location_manager_delegate_01-p.html). From here we check the activity and adjust our desiredAccuracy and distanceFilter accordingly. 

    ```groovy
    - (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager desiredAccuracyForActivity:(PSActivityType)activityType withConfidence:(PSActivityConfidence)confidence
    {
		...
        
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

    - (CLLocationDistance)psLocationManager:(PSLocationManager *)manager distanceFilterForActivity:(PSActivityType)activityType withConfidence:(PSActivityConfidence)confidence
    {
        ...     
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
