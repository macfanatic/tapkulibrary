//
//  TKAlertView.m
//  TapkuLibrary
//
//  Created by Matthew Brewer on 3/8/11.
//  Copyright 2011 University of Tennessee: College of Business. All rights reserved.
//

#import "TKAlertView.h"
#import "UIView+TKCategory.h"

@implementation TKAlertView

- (id)init {
	return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (id)initWithFrame:(CGRect)frame {
	if ( (self = [super initWithFrame:frame]) ) {
		messageRect = CGRectInset(self.bounds, 10, 10);
		self.backgroundColor = [UIColor clearColor];
	} return self;
}

- (void)adjust {
	
	CGSize s = [text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(160,200) lineBreakMode:UILineBreakModeWordWrap];
	
	float imageAdjustment = 0;
	if (image) {
		imageAdjustment = 7+image.size.height;
	}
	
	self.bounds = CGRectMake(0, 0, s.width+40, s.height+15+15+imageAdjustment);
	
	messageRect.size = s;
	messageRect.size.height += 5;
	messageRect.origin.x = 20;
	messageRect.origin.y = 15+imageAdjustment;
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
	
}

- (void)drawRect:(CGRect)rect{
	[UIView drawRoundRectangleInRect:rect withRadius:10 color:[UIColor colorWithWhite:0 alpha:0.8]];
	[[UIColor whiteColor] set];
	[text drawInRect:messageRect withFont:[UIFont boldSystemFontOfSize:14] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
	CGRect r = CGRectZero;
	r.origin.y = 15;
	r.origin.x = (rect.size.width-image.size.width)/2;
	r.size = image.size;
	
	[image drawInRect:r];
}

- (void)dealloc {
	self.text = nil;
	self.image = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Properties
@synthesize text, image;
@synthesize blocking, completion;

- (void)setText:(NSString *)s {
	if ( s != text ) {
		[text release];
		text = [s retain];
		[self adjust];
	}
}

- (void)setImage:(UIImage *)img {
	if ( img != image ) {
		[image release];
		image = [img retain];
		[self adjust];
	}
}


@end
