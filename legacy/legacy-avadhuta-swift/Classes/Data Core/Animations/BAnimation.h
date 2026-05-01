//
//  BAnimation.h
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBasicAction.h"
#import "BXMLDeserializableObject.h"
#import "BAnimation.h"
#import "BAnimationTarget.h"

@interface BAnimation : NSObject<BXMLDeserializableObject>
{
	NSMutableArray*		_actions;
	CGPoint				_center;
	CGSize				_size;
	
	float				_startDelay;
	float				_delayBetweenCycles;
	
	BOOL				_autostart;
	BOOL				_repeat;
	
	BAnimationTarget*	_target;
	
	BOOL				_started;
	BOOL				_initiallyStarted;
	
	float				_currentStartDelay;
	BOOL				_currentWaitingBetweenCyclesLoop;
	float				_currentBetweenCyclesDelay;
	
	NSString*			_name;
}

@property(readonly)	NSString*	name;
@property(readonly) UIView*		targetView;
@property(assign)	BOOL		started;
@property(assign)	BOOL		initiallyStarted;

- (void)createTargetView;
- (void)disposeTargetView;

- (void)update:(float)delta;
- (void)reset;

@end

