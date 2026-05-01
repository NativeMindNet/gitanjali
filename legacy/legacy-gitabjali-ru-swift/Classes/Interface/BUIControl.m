//
//  BUIControl.m
//  books
//
//  Created by Dmitriy Panin on 10.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIControl.h"

@interface BUIControl(Private)
- (void)_onBtn;
@end

@implementation BUIControl

@synthesize type = _type;
@synthesize controlInfo = _info;

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
}

- (void)dealloc
{
	[_btn release];
	[_info release];
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
		
		self.center = info.center;
		self.userInteractionEnabled = YES;
		
		_btn = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
		_btn.frame = self.bounds;
		_btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
		if(info.normalImage)
		{
			[_btn setImage: info.normalImage forState: UIControlStateNormal];
		}
		
		if(info.highlightedImage)
		{
			[_btn setImage: info.highlightedImage forState: UIControlStateHighlighted];
		}
		
		if(info.disabledImage)
		{
			[_btn setImage: info.disabledImage forState: UIControlStateDisabled];
		}
		
		[_btn addTarget: self
				 action: @selector(_onBtn) 
	   forControlEvents: UIControlEventTouchUpInside];
		
		[self addSubview: _btn];
		
    }
    
    return self;
}

- (void)_onBtn
{	
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: _type],BUIControlTypeKey, 
							_info, BUIControlInfoKey, nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: BUIControlDidPressedNotification 
														object: self
													  userInfo: params];
}

@end
