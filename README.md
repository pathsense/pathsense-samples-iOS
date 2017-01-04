# Pathsense Samples for iOS

A collection of sample applications demonstrating how to use the Pathsense iOS SDK. For more information, take a look at the [documentation](https://developer.pathsense.com/documentation) or connect with us on our [website](https://pathsense.com/) or [developer portal](https://developer.pathsense.com/).

You can see the additional information for each sample in their respective README files.

  - [PSLocation Sample (Obj-C)](...)
  - [PSLocation LowPower Sample (Obj-C)](...)
  - [WakeUp Sample (Obj-C)](...)
  - [WakeUp Sample (Swift)](...)

# Enabling PSLocation in Your App

1. Obtain a **Pathsense SDK Client ID** and **API Key** from [here](https://pathsense.com/). Click “GET STARTED” and enter your email address.

2. Make sure you are using the latest version of Xcode (8.0+) and targeting iOS 9.0 or higher.

3. Add the PSLocation.framework to your Xcode project (This framework needs to be added to the Embedded Binaries as well).

![Screenshot1](frameworks.png?raw=true "")

4. Under the Build Phases tab in your Target, click the + button on the top left and then select New Run Script Phase. Then setup the build phase as follows. Make sure this phase is below the Embed Frameworks phase:

![Screenshot2](RunScript.png?raw=true "")

# Using Objective-C

1. In your AppDelegate add the following code to your **application:didFinishLaunchingWithOptions:**

	```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions```
	```{```
		```[PSLocation setApiKey:@"your api key here" andClientID:@"your client ID"];```
		```return YES;```
	```}```


2. Make sure to include PSLocation framework headers in your AppDelegate.h file:

# Using Swift 3.0

1. In your AppDelegate add the following code to your **application(_:didFinishLaunchingWithOptions:)**

2. Make sure to include PSLocation framework in your AppDelegate file:
