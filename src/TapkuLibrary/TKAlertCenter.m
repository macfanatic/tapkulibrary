//
//  TKAlertCenter.m
//  Created by Devin Ross on 9/29/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKAlertCenter.h"
#import "UIView+TKCategory.h"

@interface TKAlertCenter()
- (void)showAlerts;
- (void)finalAnimations;
@property (nonatomic,retain) NSMutableArray *alerts;
@property (nonatomic,retain) TKAlertView* alertView;
@end

@implementation TKAlertCenter
@synthesize alerts;
@synthesize alertView;

+ (TKAlertCenter*) defaultCenter {
	static TKAlertCenter *defaultCenter = nil;
	if (!defaultCenter) {
		defaultCenter = [[TKAlertCenter alloc] init];
	}
	return defaultCenter;
}

- (id) init{
	
	if(!(self=[super init])) return nil;
	
	self.alerts = [NSMutableArray array];	
	active = NO;
	
	alertFrame = [UIApplication sharedApplication].keyWindow.bounds;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

	return self;
}

- (void)dismissCurrent {
	if ( !active ) return;
	
	if ( self.alertView.isBlocking ) {
		[self finalAnimations];
	}
	
}

- (void) showAlerts {
	
	if ( [self.alerts count] < 1) {
		active = NO;
		return;
	}
	
	active = YES;
	
	self.alertView = [self.alerts objectAtIndex:0];
	
	alertView.transform = CGAffineTransformIdentity;
	alertView.alpha = 0;
	[[UIApplication sharedApplication].keyWindow addSubview:alertView];
	alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);
		
	CGRect rr = alertView.frame;
	rr.origin.x = (int)rr.origin.x;
	rr.origin.y = (int)rr.origin.y;
	alertView.frame = rr;
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	alertView.transform = CGAffineTransformScale(alertView.transform, 2, 2);
	
	NSLog(@"before first animation");
	[UIView animateWithDuration:0.15 animations:^() {
		
		NSLog(@"in first animation block");
		
		alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
		alertView.frame = CGRectMake((int)alertView.frame.origin.x, (int)alertView.frame.origin.y, alertView.frame.size.width, alertView.frame.size.height);
		alertView.alpha = 1;
		
	} completion:^(BOOL finished) {
		
		if ( !self.alertView.isBlocking ) {
			[self finalAnimations];
		}
				
	}];
	
}

- (void)finalAnimations {
	
	NSLog(@"first animation completed block");
	
	// depending on how many words are in the text
	// change the animation duration accordingly
	// avg person reads 200 words per minute
	NSArray* words = [self.alertView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	double animationDelay = MAX(((double)[words count]*60.0/200.0),1);
	
	[UIView animateWithDuration:0.15 delay:animationDelay options:UIViewAnimationOptionLayoutSubviews animations:^() {
		
		NSLog(@"final animations block");
		
		UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
		CGFloat degrees = 0;
		if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
		else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
		else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
		alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
		alertView.transform = CGAffineTransformScale(alertView.transform, 0.5, 0.5);
		alertView.alpha = 0;
		
	} completion:^(BOOL finished) {
		
		NSLog(@"final animations completed block");
		
		if ( self.alertView.completion ) {
			self.alertView.completion(alertView);
		}
		
		[alertView removeFromSuperview];
		[alerts removeObjectAtIndex:0];
		[self showAlerts];
		
	}];
	
}

- (void)postAlertWithView:(TKAlertView *)view {
	[self postAlertWithView:view blocking:NO completion:NULL];
}

- (void)postAlertWithView:(TKAlertView *)view blocking:(BOOL)blocking {
	[self postAlertWithView:view blocking:blocking completion:NULL];
}

- (void)postAlertWithView:(TKAlertView *)view blocking:(BOOL)blocking completion:(TKAlertViewCompletionBlock)block {
	view.blocking = blocking;
	view.completion = block;
	[self.alerts addObject:view];
	if(!active) [self showAlerts];
}

- (void)postAlertWithMessage:(NSString*)message image:(UIImage*)image {
	TKAlertView* alert = [[[TKAlertView alloc] init] autorelease];
	alert.image = image;
	alert.text = message;
	[self.alerts addObject:alert];
	if(!active) [self showAlerts];
}
	 
- (void)postAlertWithMessage:(NSString*)message {
	[self postAlertWithMessage:message image:nil];
}
	 
- (void)dealloc {
	[alerts release];
	[alertView release];
	[super dealloc];
}


CGRect subtractRect(CGRect wf,CGRect kf){
	
	
	
	if(!CGPointEqualToPoint(CGPointZero,kf.origin)){
		
		if(kf.origin.x>0) kf.size.width = kf.origin.x;
		if(kf.origin.y>0) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
		
	}else{
		
		
		kf.origin.x = abs(kf.size.width - wf.size.width);
		kf.origin.y = abs(kf.size.height -  wf.size.height);
		
		
		if(kf.origin.x > 0){
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}else if(kf.origin.y > 0){
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
		
	}
	return CGRectIntersection(wf, kf);
	
	
	
}

- (void) keyboardWillAppear:(NSNotification *)notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kf = [aValue CGRectValue];
	CGRect wf = [UIApplication sharedApplication].keyWindow.bounds;
	
	[UIView beginAnimations:nil context:nil];
	alertFrame = subtractRect(wf,kf);
	alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);

	[UIView commitAnimations];

}
- (void) keyboardWillDisappear:(NSNotification *) notification {
	alertFrame = [UIApplication sharedApplication].keyWindow.bounds;

}
- (void) orientationWillChange:(NSNotification *) notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
	
	
	
	
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	
	[UIView beginAnimations:nil context:nil];
	alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	alertView.frame = CGRectMake((int)alertView.frame.origin.x, (int)alertView.frame.origin.y, (int)alertView.frame.size.width, (int)alertView.frame.size.height);
	[UIView commitAnimations];
	
}

@end