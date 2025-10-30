# PathSense Samples for iOS

A collection of sample applications demonstrating how to use the **PathSense iOS SDK v1.5.1**.

For more information, refer to the **latest documentation**:  
👉 [https://docs.pathsense.io/ios/html/](http://docs.pathsense.io/ios/html/)  
or visit the [PathSense website](https://pathsense.com/).

> The legacy developer portal (`developer.pathsense.com`) is no longer active.

You can find additional details for each sample in their respective README files:

  - [PSLocation Sample (Obj-C)](PSLocationSample/README.md)  
  - [PSLocation LowPower Sample (Obj-C)](PSLocationLowPowerSample/README.md)  
  - [PSLocation Ambient Sample (Obj-C)](PSLocationAmbientSample/README.md)  
  - [WakeUp Sample (Obj-C)](WakeUpSampleObj-C/README.md)  
  - [WakeUp Sample (Swift)](WakeUpSample/README.md)  
  - [Trips Basic Sample (Swift)](TripsBasicSample/README.md)

---

# Enabling PSLocation in Your App

1. **Obtain credentials**  
   Contact [PathSense](https://pathsense.com/) to request your **Client ID** and **API Key** for the iOS SDK v1.5.1.  
   > The old “GET STARTED” flow is no longer active — credentials are issued privately.

2. **Project requirements**  
   - Xcode 16 or newer  
   - iOS 14.0 or later  
   - Swift 5.9 or Objective-C  

3. **Add the framework**  
   Add **PSLocation.xcframework** (or **PSLocation.framework**) to your Xcode project.  
   Make sure it is listed under **Frameworks, Libraries and Embedded Content** and set to **Embed & Sign**.

   ![Screenshot1](frameworks.png?raw=true "")

4. **Add a Run Script build phase**  
   In **Build Phases** of your target, click ➕ → **New Run Script Phase** and configure it as shown below.  
   Make sure this phase appears *below* **Embed Frameworks**.

   ![Screenshot2](RunScript.png?raw=true "")

---

# Using Objective-C

1. In your **AppDelegate**, add the following to  
   `application:didFinishLaunchingWithOptions:`:

    ```objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        [PSLocation setApiKey:@"YOUR_API_KEY" andClientID:@"YOUR_CLIENT_ID"];
        return YES;
    }
    ```

2. Import the PSLocation framework header in **AppDelegate.h**:

    ```objective-c
    #import <PSLocation/PSLocation.h>
    ```

---

# Using Swift

1. In your **AppDelegate**, add the following to  
   `application(_:didFinishLaunchingWithOptions:)`:

    ```swift
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PSLocation.setApiKey("YOUR_API_KEY", andClientID: "YOUR_CLIENT_ID")
        return true
    }
    ```

2. Import the PSLocation framework:

    ```swift
    import PSLocation
    ```

---

© PathSense Inc. — Updated for SDK v1.5.1 / Xcode 16 / iOS 18
