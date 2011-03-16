//
//  TKAlertView.h
//  TapkuLibrary
//
//  Created by Matthew Brewer on 3/8/11.
//  Copyright 2011 University of Tennessee: College of Business. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKAlertView;
typedef void (^TKAlertViewCompletionBlock)(TKAlertView* view);

@interface TKAlertView : UIView {
	CGRect messageRect;
	NSString *text;
	UIImage *image;
	
	BOOL blocking;
	TKAlertViewCompletionBlock completion;
	
}

@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, getter=isBlocking) BOOL blocking;
@property (nonatomic, copy) TKAlertViewCompletionBlock completion;

@end
