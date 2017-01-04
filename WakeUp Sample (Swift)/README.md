# Setup for WakeUp Sample (Swift)

Obtain a **Pathsense SDK Client ID** and **API Key** from [here](https://pathsense.com/). Click “GET STARTED” and enter your email address.

Make sure you are using the latest version of Xcode (8.0+) and targeting iOS 9.0 or higher.

Add the PSLocation.framework to your Xcode project (This framework needs to be added to the Embedded Binaries as well).

![Screenshot1](../frameworks.png?raw=true "")

4. Under the Build Phases tab in your Target, click the + button on the top left and then select New Run Script Phase. Then setup the build phase as follows. Make sure this phase is below the Embed Frameworks phase:

![Screenshot2](../RunScript.png?raw=true "")

5. In your AppDelegate add the following code to your **application(_:didFinishLaunchingWithOptions:)**

    ```groovy
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        PSLocation.setApiKey("your api key here", andClientID: "your client ID")
        return true
    }
	```
6. Make sure to include PSLocation framework in your AppDelegate file:

    ```groovy
	import PSLocation
	```

