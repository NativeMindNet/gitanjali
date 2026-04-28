//
//  BScaleAction.m
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BScaleAction.h"

@implementation BScaleAction

@synthesize startScale = _startScale;
@synthesize endScale = _endScale;

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		_startScale = 1.0f;
		_endScale = 1.0f;
	}
	
	return self;
}

- (void)update:(float)dt
{
	[super update: dt];
	
	float scale = _startScale + self.currentCycleProgress * (_endScale - _startScale);
	
	if(_tagret)
	{
		_tagret.transform = CGAffineTransformScale(_tagret.transform, scale, scale);
	}
}

- (void)reset
{
	[super reset];
	
	if(_tagret)
	{
		_tagret.transform = CGAffineTransformScale(_tagret.transform, _startScale, _startScale);
	}
}

+ (id)deserialize:(xmlNodePtr)node
{
	BScaleAction* instance = [[[BScaleAction alloc] init] autorelease];
	
	xmlChar* startScaleProp = xmlGetProp(node, (xmlChar*)"start-scale");
	
	if(startScaleProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)startScaleProp];
		instance->_startScale = [str floatValue];
		xmlFree(startScaleProp);
	}
	
	xmlChar* endScaleProp = xmlGetProp(node, (xmlChar*)"end-scale");
	
	if(endScaleProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)endScaleProp];
		instance->_endScale = [str floatValue];
		xmlFree(endScaleProp);
	}
	
	return instance;
}

@end
