//
//  UserLocationAnnotationView.m
//  PSLocationTracker
//
//  Created by Paul Schmitt on 8/6/15.
//  Copyright (c) 2015 PathSense. All rights reserved.
//

#import "UserLocationAnnotationView.h"

@implementation UserLocationAnnotationView

//----------------------------------------------------------------------------------
- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"GeoCircle"];
        [self setFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
        [self setBackgroundColor:[[UIColor cyanColor] colorWithAlphaComponent:.25]];
        [[self layer] setCornerRadius:15.0];
        [[self layer] setContents:(id)[image CGImage]];
    }
    return self;
}
@end
