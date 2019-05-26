//
//  AppDelegate.m
//  PSObserver
//
//  Created by Paul Schmitt on 11/11/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import "AppDelegate.h"
#import "ObservationManager.h"
#import "SettingsViewController.h"

@implementation AppDelegate

//----------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#warning Add your api key & client ID here. Visit www.pathsense.com.
	[PSLocation setApiKey:@"your api key here" andClientID:@"your client id here"];

    ObservationManager *manager = [ObservationManager instance];
	if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
    	//Code to handle the location update
        [manager locationLaunch:application];
    }

    return YES;
}
//----------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
//----------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
//----------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[[self viewController] mapView] setNeedsDisplay];
}
//----------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[AppDelegate removeOldObservations];
}
//----------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[ObservationManager instance] saveContext];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (ViewController *)viewController
{
    return (ViewController *)[[self window] rootViewController];
}
//----------------------------------------------------------------------------------
+ (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.pathsense.PSObserver" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
//----------------------------------------------------------------------------------
+ (void)removeOldObservations
{
	NSInteger days = [SettingsViewController removeDataAfterDays];
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:now - (86400 * days)];
    [[ObservationManager instance] removeObservationaPriorTo:date];
}
@end
