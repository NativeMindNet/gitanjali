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

	BAnimationTarget*	_target;
	
	float				_currentStartDelay;
}

@property(readonly) UIView*	targetView;

- (void)createTargetView;
- (void)disposeTargetView;

- (void)update:(float)delta;
- (void)reset;

@end

