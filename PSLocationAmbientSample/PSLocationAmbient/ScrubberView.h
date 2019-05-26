//
//  ScrubberView.h
//  PSObserver
//
//  Created by Paul Schmitt on 11/18/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrubberViewDelegate;

@interface ScrubberView : UIVisualEffectView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *numberOfLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) IBOutlet UIButton *leftButton;
@property (nonatomic, strong) IBOutlet UIButton *rightButton;
@property (nonatomic, weak) id<ScrubberViewDelegate> delegate;

@end

//----------------------------------------------------------------------------------
@protocol ScrubberViewDelegate <NSObject>

@required

@optional
- (void)scrubberView:(ScrubberView*)scrubberView valueChanged:(float)value;
@end

