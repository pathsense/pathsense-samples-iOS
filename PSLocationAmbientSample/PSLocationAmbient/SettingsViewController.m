//
//  SettingsViewController.m
//

#import <CoreMotion/CoreMotion.h>
#import "SettingsViewController.h"

enum {
    kMainSection = 0,
    kUseIncreaseFrequencyWhenPossibleRowIndex= 0,
    kMinTimeToRemainAwakeIndex,
    kMaxDaysToKeepDataIndex,
    kUseActivityRowIndex,
    kMainSectionRows = kUseActivityRowIndex + 1,
    
    kTableSections = kMainSection + 1
};

@interface SettingsViewController ()

	- (void) handleCancelButton:(id)sender;
	- (void) handleDoneButton:(id)sender;

@property (nonatomic) CGFloat sliderWidth;
@end

@implementation SettingsViewController

//----------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    [_table setSectionHeaderHeight:1];
    [_table setSectionFooterHeight:60];
    
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleDoneButton:)];
    [[self navigationItem] setRightBarButtonItem:_doneButton];
    
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancelButton:)];
    [[self navigationItem] setLeftBarButtonItem:_cancelButton];
}
//----------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect r = [_table frame];
    _sliderWidth = r.size.width * .3f;

    [_table reloadData];
}
//----------------------------------------------------------------------------------
- (BOOL)prefersStatusBarHidden
{
	return NO;
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void) handleCancelButton:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
    	if ([[self delegate] respondsToSelector:@selector(settingsViewControllerDidCancel:)] == YES) {
        	[[self delegate] settingsViewControllerDidCancel:self];
        }
    }];
}
//----------------------------------------------------------------------------------
- (void) handleDoneButton:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		if ([[self delegate] respondsToSelector:@selector(settingsViewControllerDidFinish:)] == YES) {
        	[[self delegate] settingsViewControllerDidFinish:self];
        }
    }];
}
//----------------------------------------------------------------------------------
- (void) handleSegmentedControl:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    NSUInteger section = [segmentedControl tag]/100;
    NSUInteger row = [segmentedControl tag]%100;
    switch (section) {
		case kMainSection:
			switch (row) {
                case kMinTimeToRemainAwakeIndex:
                {
					if ([segmentedControl selectedSegmentIndex] == 0) {
						[SettingsViewController setAllowedWakeTime:0];
					} else if ([segmentedControl selectedSegmentIndex] == 1) {
						[SettingsViewController setAllowedWakeTime:60];
					} else if ([segmentedControl selectedSegmentIndex] == 2) {
						[SettingsViewController setAllowedWakeTime:60 * 2];
					} else if ([segmentedControl selectedSegmentIndex] == 3) {
						[SettingsViewController setAllowedWakeTime:60 * 3];
					}
                }
                break;

                case kMaxDaysToKeepDataIndex:
                {
					if ([segmentedControl selectedSegmentIndex] == 0) {
						[SettingsViewController setRemoveDataAfterDays:7];
					} else if ([segmentedControl selectedSegmentIndex] == 1) {
						[SettingsViewController setRemoveDataAfterDays:14];
					} else if ([segmentedControl selectedSegmentIndex] == 2) {
						[SettingsViewController setRemoveDataAfterDays:30];
					}
                }
                break;
			}
        break;
					
      	default:
        break;
    }
}
//----------------------------------------------------------------------------------
- (void) handleSwitchView:(id)sender
{
	UISwitch *switchView = sender;
    NSUInteger section = [switchView tag]/100;
    NSUInteger row = [switchView tag]%100;
    
    switch (section) {
		case kMainSection:
			switch (row) {
                case kUseActivityRowIndex:
                {
                    BOOL state = ![SettingsViewController useActivity];
                    [SettingsViewController setUseActivity:state];
                    [switchView setOn:state animated:YES];
                }
                break;
                
                case kUseIncreaseFrequencyWhenPossibleRowIndex:
                {
                    BOOL state = ![SettingsViewController useIncreaseFrequencyWhenPossible];
                    [SettingsViewController setUseIncreaseFrequencyWhenPossible:state];
                    [switchView setOn:state animated:YES];
                }
                break;
			}
        break;
        
      	default:
        break;
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = 44;
    return result;
}
//----------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger result = kTableSections;
    return result;
}
//----------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 0;
    switch (section) {
      case kMainSection:
        result = kMainSectionRows;
		if ([CMMotionActivityManager isActivityAvailable] == NO) {
        	result -= 1;
        }
        break;

      default:
        break;
    }
    return result;
}
//----------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat result = [tableView sectionHeaderHeight];
    return result;
}
//----------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *result = nil;
    switch (section) {
    
      case kMainSection:
      	result = CopyrightString(2017);
        break;

		default:
		break;
    }
    return result;
}
//----------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat result = [tableView sectionFooterHeight];
    return result;
}
//----------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    [cell setAccessoryView:nil];
    [[cell textLabel] setText:nil];
    [[cell detailTextLabel] setText:nil];
    [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont labelFontSize]]];
    [[cell detailTextLabel] setNumberOfLines:0];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[cell textLabel] setTextColor:[UIColor blackColor]];

    switch ([indexPath section]) {
		case kMainSection:
			switch ([indexPath row]) {
            	case kUseIncreaseFrequencyWhenPossibleRowIndex:
                [[cell textLabel] setText:@"Use Increased Frequency"];
                {
                    UISwitch *switchView = [UISwitch new];
                    [switchView addTarget:self action:@selector(handleSwitchView:) forControlEvents:UIControlEventTouchUpInside];
                    [switchView setOn:[SettingsViewController useIncreaseFrequencyWhenPossible]];
                    [switchView setTag:([indexPath section]*100)+[indexPath row]];
                    [cell setAccessoryView:switchView];
                }
                break;
					
                case kMaxDaysToKeepDataIndex:
                    [[cell textLabel] setText:@"Delete Data Older Than n Days"];
                    {
                        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"7", @"14", @"30"]];
                         [segmentedControl addTarget:self action:@selector(handleSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                         if ([SettingsViewController removeDataAfterDays] == 7) {
                              [segmentedControl setSelectedSegmentIndex:0];
                        } else if ([SettingsViewController removeDataAfterDays] == 14) {
                            [segmentedControl setSelectedSegmentIndex:1];
                        } else {
                          	[segmentedControl setSelectedSegmentIndex:2];
                        }

                        [segmentedControl setTag:([indexPath section]*100)+[indexPath row]];
                        [segmentedControl setEnabled:[[cell textLabel] isEnabled]];
						[cell setAccessoryView:segmentedControl];
                    }
                break;
					
                case kMinTimeToRemainAwakeIndex:
                {
                    [[cell textLabel] setText:@"Allowed Awake Time (min.)"];
                    {
                        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"0", @"1", @"2", @"3"]];
                         [segmentedControl addTarget:self action:@selector(handleSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                         if ([SettingsViewController allowedWakeTime] == 60) {
                              [segmentedControl setSelectedSegmentIndex:1];
                        } else if ([SettingsViewController allowedWakeTime] == 60 * 2) {
                            [segmentedControl setSelectedSegmentIndex:2];
                        } else if ([SettingsViewController allowedWakeTime] == 60 * 3) {
                            [segmentedControl setSelectedSegmentIndex:3];
                        } else {
                          	[segmentedControl setSelectedSegmentIndex:0];
                        }
                     
                        [segmentedControl setTag:([indexPath section]*100)+[indexPath row]];
                        [segmentedControl setEnabled:[[cell textLabel] isEnabled]];
						[cell setAccessoryView:segmentedControl];
                    }
                }
                break;

            	case kUseActivityRowIndex:
                [[cell textLabel] setText:@"Use Activity"];
                {
                    UISwitch *switchView = [UISwitch new];
                    [switchView addTarget:self action:@selector(handleSwitchView:) forControlEvents:UIControlEventTouchUpInside];
                    [switchView setOn:[SettingsViewController useActivity]];
                    [switchView setTag:([indexPath section]*100)+[indexPath row]];
                    [cell setAccessoryView:switchView];

					if ([CMMotionActivityManager authorizationStatus] == CMAuthorizationStatusAuthorized || [CMMotionActivityManager authorizationStatus] == CMAuthorizationStatusNotDetermined) {
						[switchView setEnabled:YES];
						
					} else {
						[switchView setOn:NO animated:YES];
						[switchView setEnabled:NO];
					}
                }
                break;
                
				default:
				break;
			}
        break;
        default:
        break;
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}
//----------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
//----------------------------------------------------------------------------------
+ (BOOL)useIncreaseFrequencyWhenPossible
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (DefaultsContainsKey(@"useIncreaseFrequencyWhenPossible") == NO) {
    	[self setUseIncreaseFrequencyWhenPossible:YES];
    }
    BOOL result = [defaults boolForKey:@"useIncreaseFrequencyWhenPossible"];
    return result;
}
//----------------------------------------------------------------------------------
+ (void)setUseIncreaseFrequencyWhenPossible:(BOOL)useIncreaseFrequencyWhenPossible
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:useIncreaseFrequencyWhenPossible forKey:@"useIncreaseFrequencyWhenPossible"];
    [defaults synchronize];
}
//----------------------------------------------------------------------------------
+ (BOOL)useActivity
{
    if ([CMMotionActivityManager isActivityAvailable] == NO) {
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (DefaultsContainsKey(@"useActivity") == NO) {
        [self setUseActivity:NO];
    }
    BOOL result = [defaults boolForKey:@"useActivity"];
    return result;
}
//----------------------------------------------------------------------------------
+ (void)setUseActivity:(BOOL)useActivity
{
    if ([CMMotionActivityManager isActivityAvailable] == NO) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:useActivity forKey:@"useActivity"];
    [defaults synchronize];
}
//----------------------------------------------------------------------------------
+ (NSTimeInterval)allowedWakeTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (DefaultsContainsKey(@"allowedWakeTime") == NO) {
        [self setAllowedWakeTime:0];
    }
    NSTimeInterval result = [defaults doubleForKey:@"allowedWakeTime"];
    return result;
}
//----------------------------------------------------------------------------------
+ (void)setAllowedWakeTime:(NSTimeInterval)allowedWakeTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:allowedWakeTime forKey:@"allowedWakeTime"];
    [defaults synchronize];
}
//----------------------------------------------------------------------------------
+ (NSInteger)removeDataAfterDays
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (DefaultsContainsKey(@"removeDataAfterDays") == NO) {
        [self setRemoveDataAfterDays:7];
    }
    NSInteger result = [defaults integerForKey:@"removeDataAfterDays"];
    return result;
}
//----------------------------------------------------------------------------------
+ (void)setRemoveDataAfterDays:(NSInteger)days
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:days forKey:@"removeDataAfterDays"];
    [defaults synchronize];
}

#pragma mark -
//----------------------------------------------------------------------------------
NSString* CopyrightString(NSUInteger releaseYear)
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponent = [gregorian components:(NSCalendarUnitYear) fromDate:today];

    NSString *str = nil;
    if (releaseYear == [dateComponent year]) {
        str = NSLocalizedString(@"Copyright © %d PathSense Inc.\rAll rights reserved.\rVersion %@ (%@)", nil);
        return [NSString stringWithFormat:str, releaseYear, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    } else {
        str = NSLocalizedString(@"Copyright © %d-%d PathSense Inc.\rAll rights reserved.\rVersion %@ (%@)", nil);
        return [NSString stringWithFormat:str, releaseYear, [dateComponent year], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    }
}
//----------------------------------------------------------------------------------
BOOL DefaultsContainsKey(NSString *inKey)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [[defaults dictionaryRepresentation] allKeys];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF=%@", inKey];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
    return ([filteredArray count] != 0);
}
@end

