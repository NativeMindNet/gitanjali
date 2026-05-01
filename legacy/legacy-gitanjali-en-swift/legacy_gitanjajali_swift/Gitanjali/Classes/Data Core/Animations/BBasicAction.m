//
//  BBasicAction.m
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBasicAction.h"
#import "BScaleAction.h"
#import "BRotationAction.h"
#import "BFadeAction.h"
 
@interface BBasicAction(Private)
- (void)_nextCycle;
@end


@implementation BBasicAction

@synthesize duration = _duration;
@synthesize repeatCount = _repeatCount;
@synthesize autoreverse = _autoreverse;
@synthesize currentCycleProgress = _currentProgress;

- (UIView*)target
{
	return _tagret;
}

- (void)setTarget:(UIView *)target
{
	_tagret = target;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		_duration = 0.5;
		_repeatCount = 0;
		_autoreverse = NO;
	}
	return self;
}

- (BOOL)finished
{
	if(_repeatCount > 0 &&  _currentCycle >= _repeatCount)
	{
		return YES;
	}
	
	return NO;
}

- (void)update:(float)dt
{
	if(self.finished)
	{
		return;
	}
	
	if(!_reversing)
	{
		_currentProgress += dt / _duration;
		
		if(_currentProgress > 1.0f)
		{
			_currentProgress = 1.0f;
			
			if(_autoreverse)
			{
				_reversing = YES;
			}
			else 
			{
				[self _nextCycle];
			}

		}
	}
	else
	{
		_currentProgress -= dt / _duration;
		
		if(_currentProgress <= 0.0f)
		{
			_currentProgress = 0.0f;
			
			[self _nextCycle];
		}
	}
}

- (void)reset
{
	_currentProgress = 0.0f;
	_currentCycle = 0; 	
	_reversing = NO;
}

- (void)_nextCycle
{
	_reversing = NO;

	if(_repeatCount <= 0)
	{
		_currentProgress = 0.0f;
	}
	
	_currentCycle++;
	
	if(_currentCycle < _repeatCount)
	{
		_currentProgress = 0.0f;
	}
}

+ (id)deserialize:(xmlNodePtr)node
{
	xmlChar* typeProp = xmlGetProp(node, (xmlChar*)"type");
	
	if(!typeProp)
	{
		return nil;
	}
	
	NSString* type = [NSString stringWithUTF8String: (const char*)typeProp];
	
	xmlFree(typeProp);
	
	BBasicAction* instance = nil;
	
	if([type isEqualToString: @"rotation"])
	{
		instance = [BRotationAction deserialize: node];
	}
	
	if([type isEqualToString: @"scale"])
	{
		instance = [BScaleAction deserialize: node];
	}
	
	if([type isEqualToString: @"fade"])
	{
		instance = [BFadeAction deserialize: node];
	}
	
	if(!instance)
	{
		return nil;
	}
	
	xmlChar* durProp = xmlGetProp(node, (xmlChar*)"duration");
	
	if(durProp)
	{
		NSString* dur = [NSString stringWithUTF8String: (const char*)durProp];
		instance->_duration = [dur floatValue];
		xmlFree(durProp);
	}
	
	xmlChar* autoreverseProp = xmlGetProp(node, (xmlChar*)"autoreverse");
	
	if(autoreverseProp)
	{
		if(!xmlStrcmp(autoreverseProp, (xmlChar*)"true"))
		{
			instance->_autoreverse = YES;
		}
		
		xmlFree(autoreverseProp);
	}	
	
	xmlChar* repeatCountProp = xmlGetProp(node, (xmlChar*)"repeats-count");
	
	if(repeatCountProp)
	{
		NSString* rc = [NSString stringWithUTF8String: (const char*)repeatCountProp];
		instance->_repeatCount = [rc intValue];
		xmlFree(repeatCountProp);
	}
	
	return instance;
}

@end
