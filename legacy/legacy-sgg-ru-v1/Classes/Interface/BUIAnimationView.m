//
//  BUIAnimationView.m
//  books
//
//  Created by Dmitry Panin on 19.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIAnimationView.h"
#import "BAnimation.h"

#define DEFAULT_UPDATE_RATE (1.0f/60.0f)

@interface BUIAnimationView(Private)
- (void)_onTimer;
- (void)_onApplicationDidRestoredFromBackground;
@end

@implementation BUIAnimationView

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	for(BAnimation* animation in _animations)
	{
		if(animation.targetView.superview == self)
		{
			[animation disposeTargetView];
		}
	}
	
	[_lastUpdateDate release];
	[_updateTimer invalidate];
	[_animations release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame animations:(NSArray*)animations
{
	if((self = [super initWithFrame: frame]))
	{
		_animations = [[NSMutableArray alloc] initWithArray: animations];
		

		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(_onApplicationDidRestoredFromBackground) 
													 name: UIApplicationDidBecomeActiveNotification
												   object: nil];
	}
	
	return self;
}

- (void)playAnimation
{
	if(_updateTimer)
	{
		return;
	}
	
	for(BAnimation* animation in _animations)
	{
		[animation createTargetView];
		
		[self addSubview: animation.targetView];
	}

	_updateTimer = [NSTimer scheduledTimerWithTimeInterval: DEFAULT_UPDATE_RATE 
													target: self 
												  selector: @selector(_onTimer) 
												  userInfo: nil 
												   repeats: YES];
}

- (void)stopAnimation
{
	for(BAnimation* animation in _animations)
	{
		if(animation.targetView.superview == self)
		{
			[animation disposeTargetView];
		}
	}
	
	[_updateTimer invalidate];
	_updateTimer = nil;
	
	[_lastUpdateDate release];
	_lastUpdateDate = nil;
	
	for(BAnimation* animation in _animations)
	{
		[animation reset];
	}
}

- (void)resetTimer
{
	[_lastUpdateDate release];
	_lastUpdateDate = nil;
}

- (void)_onTimer
{
	if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
	{
		return;
	}
	
	float delta = DEFAULT_UPDATE_RATE;
	
	if(_lastUpdateDate)
	{
		delta = fabsf([[NSDate date] timeIntervalSinceDate: _lastUpdateDate]);
	}
	
	for(BAnimation* animation in _animations)
	{
		[animation update: delta];
	}
}

- (void)_onApplicationDidRestoredFromBackground
{
	[self resetTimer];
}

@end
