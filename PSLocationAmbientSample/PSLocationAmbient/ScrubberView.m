//
//  ScrubberView.m
//  PSObserver
//
//  Created by Paul Schmitt on 11/18/15.
//  Copyright © 2015 PathSense. All rights reserved.
//

#define kSliderHeight	36.0
#define kSliderInset	75.0
#define kLabelWidth		150.0
#define kLabelHeight	20

#import "ScrubberView.h"

@interface ScrubberView ()

@property (nonatomic, strong) UIVisualEffectView *labelBorder;

- (void) positionLabel;

@end

@implementation ScrubberView

//----------------------------------------------------------------------------------
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
    	[[self layer]  setBorderWidth:1.0];
    	[[self layer]  setBorderColor:[[UIColor lightGrayColor] CGColor]];
    	[[self layer]  setMasksToBounds:YES];
        
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_slider setTintColor:[UIColor darkGrayColor]];
        [_slider setContinuous:YES];
        [_slider addTarget:self action:@selector(handleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [[self contentView] addSubview:_slider];
        
		_labelBorder = [[UIVisualEffectView alloc] initWithFrame:CGRectZero];
		[_labelBorder setEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *)[self effect]]];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    	[[backgroundView layer]  setCornerRadius:kLabelHeight*.5];
    	[[backgroundView layer]  setMasksToBounds:YES];
        [[_labelBorder contentView] addSubview:backgroundView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
    	[[_label layer]  setCornerRadius:kLabelHeight*.5];
    	[[_label layer]  setBorderWidth:1.0];
    	[[_label layer]  setBorderColor:[[UIColor darkGrayColor] CGColor]];
    	[[_label layer]  setMasksToBounds:YES];
		[_label setTextColor:[UIColor darkGrayColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_label setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [_label setAdjustsFontSizeToFitWidth:YES];
        [[self contentView] addSubview:_label];
        [[self contentView] addSubview:_labelBorder];

        _numberOfLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_numberOfLabel setAdjustsFontSizeToFitWidth:YES];
		[_numberOfLabel setTextColor:[UIColor grayColor]];
        [_numberOfLabel setTextAlignment:NSTextAlignmentCenter];
        [_numberOfLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]-2]];
        [[self contentView] insertSubview:_numberOfLabel belowSubview:_slider];
        
    }
    return self;
}
//----------------------------------------------------------------------------------
-(void) layoutSubviews
{
	CGRect bounds = [self bounds];
    
    CGRect r = CGRectInset(bounds, 10 + [_leftButton frame].size.width, 0);
    r.origin.y = r.size.height - kSliderHeight-2.0;
    r.size.height = kSliderHeight;
    [_slider setFrame:r];
    
    r.size.height = 16;
    r.origin.y = bounds.size.height - r.size.height;
    [_numberOfLabel setFrame:r];
    
    r = [_leftButton frame];
    r.origin.x = 5;
    r.origin.y = bounds.size.height - r.size.height - 8.0;
    [_leftButton setFrame:r];
    
    r = [_rightButton frame];
    r.origin.x = bounds.size.width - r.size.width - 5.0;
    r.origin.y = bounds.size.height - r.size.height - 8.0;
    [_rightButton setFrame:r];
    
    [self positionLabel];
}

#pragma mark -
//----------------------------------------------------------------------------------
- (void) positionLabel
{
    CGRect r = [_slider frame];
    CGRect trackRect = [_slider trackRectForBounds:r];
    trackRect = CGRectInset(trackRect, -([_rightButton frame].size.width+5), 0);
	CGRect thumbRect = [_slider thumbRectForBounds:[_labelBorder bounds] trackRect:trackRect value:[_slider value]];
    
	r.origin.x = thumbRect.origin.x - (kLabelWidth * [_slider value]) + (thumbRect.size.width * [_slider value]);
    r.origin.y = [_slider frame].origin.y - kLabelHeight;
    r.size.width = kLabelWidth;
    r.size.height = kLabelHeight;
    [_labelBorder setFrame:r];
    [_label setFrame:r];
}
//----------------------------------------------------------------------------------
- (void) handleSliderValueChanged:(id)sender
{
    [self positionLabel];

	if ([_delegate respondsToSelector:@selector(scrubberView:valueChanged:)]) {
    	[_delegate scrubberView:self valueChanged:[_slider value]];
    }
}

@end
