//
//  BRotationAction.m
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BRotationAction.h"

@implementation BRotationAction

@synthesize startAngle = _startAngle;
@synthesize finishAngle = _finishAngle;

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		_startAngle = 0.0f;
		_finishAngle = 0.0f;
	}
	
	return self;
}

- (void)update:(float)dt
{
	[super update: dt];
	
	float rot = _startAngle + self.currentCycleProgress * (_finishAngle - _startAngle);
	
	if(_tagret)
	{
		_tagret.transform = CGAffineTransformRotate(_tagret.transform, rot * M_PI / 180.0f);
	}
}

- (void)reset
{
	[super reset];
	
	if(_tagret)
	{
		_tagret.transform = CGAffineTransformRotate(_tagret.transform, _startAngle * M_PI/ 180);
	}
}

+ (id)deserialize:(xmlNodePtr)node
{
	BRotationAction* instance = [[[BRotationAction alloc] init] autorelease];
	
	xmlChar* startScaleProp = xmlGetProp(node, (xmlChar*)"start-angle");
	
	if(startScaleProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)startScaleProp];
		instance->_startAngle = [str floatValue];
		xmlFree(startScaleProp);
	}
	
	xmlChar* endScaleProp = xmlGetProp(node, (xmlChar*)"end-angle");
	
	if(endScaleProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)endScaleProp];
		instance->_finishAngle = [str floatValue];
		xmlFree(endScaleProp);
	}
	
	return instance;
}

@end
