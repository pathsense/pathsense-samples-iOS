//
//  SliderDisplayView.m
//
//  Created by Paul Schmitt on 3/18/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import "SliderDisplayView.h"

@implementation SliderDisplayView

//----------------------------------------------------------------------------------
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	CGRect r = [self bounds];
        r.size.height *= .5;
        _centerLabel = [[UILabel alloc] initWithFrame:r];
        [_centerLabel setBackgroundColor:[UIColor clearColor]];
        [_centerLabel setTextColor:[UIColor darkGrayColor]];
        [_centerLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [_centerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_centerLabel];
        
        r.origin.y = r.size.height + 5;
        r.size.height -= 10;
		_slider = [[UISlider alloc] initWithFrame:r];
        [_slider addTarget:self action:@selector(handleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider setBackgroundColor:[UIColor clearColor]];
        [_slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_slider];
        
    	[self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
//----------------------------------------------------------------------------------
- (void) dealloc
{
	[self removeObserver:self forKeyPath:@"enabled"];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void) handleSliderValueChanged:(id)sender
{
	if ([_delegate respondsToSelector:@selector(sliderDisplayView:valueChanged:)] == YES) {
    	[_delegate sliderDisplayView:self valueChanged:[_slider value]];
    }
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"enabled"] == YES) {
    	[_slider setEnabled:_enabled];
    	[_centerLabel setEnabled:_enabled];
    }
}
@end
