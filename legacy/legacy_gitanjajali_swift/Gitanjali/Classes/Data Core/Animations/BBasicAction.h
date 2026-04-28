//
//  BBasicAction.h
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXMLDeserializableObject.h"


@interface BBasicAction : NSObject<BXMLDeserializableObject>
{
	float		_duration;
	int			_repeatCount;
	BOOL		_autoreverse;
	
	float		_currentProgress;
	int			_currentCycle;
	BOOL		_reversing;
	UIView*		_tagret;
}

@property(assign)	float		duration;
@property(assign)	int			repeatCount;
@property(assign)	BOOL		autoreverse;

@property(assign)	UIView*		target;

@property(readonly)	BOOL		finished;
@property(readonly)	float		currentCycleProgress;

- (void)update:(float)dt;
- (void)reset;

@end
