//
//  BFadeAction.m
//  books
//
//  Created by Dmitry Panin on 04.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BFadeAction.h"

@implementation BFadeAction

@synthesize startAlpha = _startAlpha;
@synthesize endAlpha = _endAlpha;

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		_startAlpha = 1.0f;
		_endAlpha = 1.0f;
	}
	
	return self;
}

- (void)update:(float)dt
{
	[super update: dt];
	
	float alpha = _startAlpha + self.currentCycleProgress * (_endAlpha - _startAlpha);
	
	if(self.target)
	{
		self.target.alpha = alpha;
	}
}

- (void)reset
{
	[super reset];
	
	if(self.target)
	{
		self.target.alpha = _startAlpha;
	}
}

+ (id)deserialize:(xmlNodePtr)node
{
	BFadeAction* instance = [[[BFadeAction alloc] init] autorelease];
	
	xmlChar* startScaleProp = xmlGetProp(node, (xmlChar*)"start-alpha");
	
	if(startScaleProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)startScaleProp];
		instance->_startAlpha = [str floatValue];
		xmlFree(startScaleProp);
	}
	
	xmlChar* endScaleProp = xmlGetProp(node, (xmlChar*)"end-alpha");
	
	if(endScaleProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)endScaleProp];
		instance->_endAlpha = [str floatValue];
		xmlFree(endScaleProp);
	}
	
	return instance;
}

@end
