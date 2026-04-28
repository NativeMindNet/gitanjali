//
//  BAnimationTarget.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BAnimationTarget.h"
#import "BImageAnimationTarget.h"
#import "BKeyframeAnimationTarget.h"
#import "BVideoAnimationTarget.h"

@implementation BAnimationTarget

@synthesize view = _view;

- (void)createView
{
	
}

- (void)disposeView
{
	
}

- (void)reset
{
	
}

- (void)update:(float)delta
{
	
}

+ (id)deserialize:(xmlNodePtr)node
{
	xmlChar* typeProp = xmlGetProp(node, (xmlChar*)"type");
	
	BAnimationTarget* instance = nil;
	
	if(!xmlStrcmp(typeProp, (xmlChar*)"keyframe"))
	{
		instance = [BKeyframeAnimationTarget deserialize: node];
	}
	
	if(!xmlStrcmp(typeProp, (xmlChar*)"image"))
	{
		instance = [BImageAnimationTarget deserialize: node];
	}
	
	if(!xmlStrcmp(typeProp, (xmlChar*)"video"))
	{
		instance = [BVideoAnimationTarget deserialize: node];
	}
	
	if(!instance)
	{
		return nil;
	}
	

	return instance;
}

@end
