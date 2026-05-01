//
//  BUIControl.m
//  books
//
//  Created by Dmitriy Panin on 10.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIControl.h"

@interface BUIControl(Private)<UIGestureRecognizerDelegate>
- (void)_onBtnTouchDown;
- (void)_onBtnTouchUpInside;
- (void)_setControlState:(BControlState)state;
- (void)_onPan;
- (void)_onLongPress;
- (void)_onDraggingDidStarted;
- (void)_onDraggingDidFinished;
@end

@implementation BUIControl

@synthesize type = _type;
@synthesize controlInfo = _info;
@synthesize state = _state;
@synthesize dragging = _dragging;

NSString* BUIControlDidPressedNotification = @"BUIControlDidPressedNotification";
NSString* BUIControlTypeKey = @"BUIControlTypeKey";
NSString* BUIControlInfoKey = @"BUIControlInfoKey";

- (BOOL)enabled
{
	return _btn.enabled;
}

- (void)setEnabled:(BOOL)enabled
{
	_btn.enabled = enabled;
	
	if(enabled)
	{
		self.alpha = 1.0f;
	}
	else
	{
		self.alpha = 0.0f;
	}
	
	if(enabled)
	{
		[self _setControlState: kControlStateNormal];
	}
	else
	{
		[self _setControlState: kControlStateDisabled];
	}
}

- (void)dealloc
{
	[_btn release];
	[_info release];
	[_panGestureRecognizer release];
	[_longPressGestureRecognizer release];
	[super dealloc];
}

- (id)initWithControlInfo:(BControlInfo*)info
{
	CGRect frame;
	frame.origin = CGPointZero;
	frame.size = info.normalImage.size;
    self = [super initWithFrame: frame];
	
    if (self) 
	{
		_type = info.type;
		_info = [info retain];
	
		self.userInteractionEnabled = YES;
		
		_btn = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
		_btn.frame = self.bounds;
		_btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_btn.adjustsImageWhenHighlighted = NO;
		_btn.adjustsImageWhenDisabled = NO;
		
		[_btn addTarget: self
				 action: @selector(_onBtnTouchDown) 
	   forControlEvents: UIControlEventTouchDown];
		
		[_btn addTarget: self
				 action: @selector(_onBtnTouchUpInside) 
	   forControlEvents: UIControlEventTouchUpInside];
		
		[_btn addTarget: self
				 action: @selector(_onBtnTouchUpInside) 
	   forControlEvents: UIControlEventTouchUpOutside];
		
		[self addSubview: _btn];
		
		[self _setControlState: kControlStateNormal];
		
		if(self.controlInfo.dragable)
		{
			_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self 
																			action: @selector(_onPan)];
			_panGestureRecognizer.delegate = self;
			
			[self addGestureRecognizer: _panGestureRecognizer];
			
			_longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self 
																						action: @selector(_onLongPress)];
			_longPressGestureRecognizer.delegate = self;
            _longPressGestureRecognizer.minimumPressDuration = 0.3;
			
			[self addGestureRecognizer: _longPressGestureRecognizer];
		}
		
    }
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)_onBtnTouchDown
{
	if(self.controlInfo.checkmark)
	{
		BControlState newState = kControlStateNormal;
		
		if(_state == kControlStateNormal)
		{
			newState = kControlStateHighlighted;
		}
		
		[self _setControlState: newState];
	}
	else
	{
		[self _setControlState: kControlStateHighlighted];
	}
}


- (void)_onBtnTouchUpInside
{	
	if(!self.controlInfo.checkmark)
	{
		if(self.enabled)
		{
			[self _setControlState: kControlStateNormal];
		}
		else
		{
			[self _setControlState: kControlStateDisabled];
		}
	}

	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: _type], BUIControlTypeKey, 
							_info, BUIControlInfoKey, nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: BUIControlDidPressedNotification 
														object: self
													  userInfo: params];
}

- (void)_setControlState:(BControlState)state
{
	_state = state;
	
	self.center = [self.controlInfo centerForState: _state];
	
	UIImage* icon = self.controlInfo.normalImage;
	
	if(_state == kControlStateHighlighted && self.controlInfo.highlightedImage)
	{
		icon = self.controlInfo.highlightedImage;
	}
	
	if(_state == kControlStateDisabled && self.controlInfo.disabledImage)
	{
		icon = self.controlInfo.disabledImage;
	}
	
	[_btn setImage:icon forState: UIControlStateNormal];
}

- (void)_onPan
{
	if(!_dragging)
	{
		return;
	}
	
	CGPoint delta = [_panGestureRecognizer translationInView: self.superview];
	
	CGPoint center = self.center;
	center.x += delta.x;
	center.y += delta.y;
	self.center = center;
	
	[self.controlInfo setCenter:center forState: UIControlStateNormal];
	[self.controlInfo setCenter:center forState: UIControlStateDisabled];
	[self.controlInfo setCenter:center forState: UIControlStateHighlighted];
	
	[_panGestureRecognizer setTranslation:CGPointZero inView: self.superview];
	
	if(_panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
	   _panGestureRecognizer.state == UIGestureRecognizerStateCancelled)
	{
		_dragging = NO;
		[self _onDraggingDidFinished];
	}
}

- (void)_onLongPress
{
	if(!_dragging)
	{
		_dragging = YES;
		[self _onDraggingDidStarted];
	}
}

- (void)_onDraggingDidStarted
{	
	_longPressGestureRecognizer.enabled = NO;
	
	[UIView animateWithDuration:0.25 
					 animations: 
					^{
						 
						 	self.transform = CGAffineTransformMakeScale(1.2, 1.2);
					}];

}

- (void)_onDraggingDidFinished
{	
	_longPressGestureRecognizer.enabled = YES;
	
	[UIView animateWithDuration:0.25 
					 animations: 
	 ^{
		 
		 self.transform = CGAffineTransformIdentity;
	 }];
}

@end
