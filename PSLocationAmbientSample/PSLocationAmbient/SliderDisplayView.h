//
//  SliderDisplayView.h
//
//  Created by Paul Schmitt on 3/18/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderDisplayViewDelegate;

@interface SliderDisplayView : UIView

@property (nonatomic, readonly) UISlider *slider;
@property (nonatomic, readonly) UILabel *centerLabel;
@property(nonatomic, weak) id<SliderDisplayViewDelegate> delegate;
@property(nonatomic, getter=isEnabled) BOOL enabled;

@end


@protocol SliderDisplayViewDelegate <NSObject>

@optional

- (void) sliderDisplayView:(SliderDisplayView *)sliderDisplayView valueChanged:(float)value;

@end
