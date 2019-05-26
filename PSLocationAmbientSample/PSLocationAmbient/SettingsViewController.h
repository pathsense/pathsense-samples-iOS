//
//  SettingsViewController.h
//  PSLocationTracker
//
//  Created by Paul Schmitt on 8/17/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, readonly) UIBarButtonItem *doneButton;
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

+ (BOOL)useIncreaseFrequencyWhenPossible;
+ (void)setUseIncreaseFrequencyWhenPossible:(BOOL)useIncreaseFrequencyWhenPossible;
+ (BOOL)useActivity;
+ (void)setUseActivity:(BOOL)useActivity;
+ (NSTimeInterval)allowedWakeTime;
+ (void)setAllowedWakeTime:(NSTimeInterval)allowedWakeTime;
+ (NSInteger)removeDataAfterDays;
+ (void)setRemoveDataAfterDays:(NSInteger)days;

@end

@protocol SettingsViewControllerDelegate <NSObject>

@optional

- (void) settingsViewControllerDidCancel:(SettingsViewController *)settingsViewController;
- (void) settingsViewControllerDidFinish:(SettingsViewController *)settingsViewController;
@end
