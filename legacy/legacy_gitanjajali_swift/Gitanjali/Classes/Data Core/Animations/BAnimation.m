//
//  BAnimation.m
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BAnimation.h"
#import "BToolFunctions.h"

@implementation BAnimation

- (UIView*)targetView
{
	return _target.view;
}

- (void)dealloc
{
	[_target release];
	[_actions release];
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		_actions = [[NSMutableArray alloc] init];
		_center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0f,
							  [UIScreen mainScreen].bounds.size.height / 2.0f);
	}
	
	return self;
}

- (void)createTargetView
{
	[_target createView];
	
	_target.view.center = _center;
	
	if(_size.width != 0 || _size.height != 0)
	{
		_target.view.bounds = CGRectMake(0.0f, 0.0f, _size.width, _size.height);
	}
	
	for(BBasicAction* anim in _actions)
	{
		anim.target = _target.view;
	}
	
	[self reset];
}

- (void)disposeTargetView
{
	[_target disposeView];
	
	for(BBasicAction* anim in _actions)
	{
		anim.target = nil;
	}
	
	[self reset];
}

- (void)update:(float)delta
{
	if(_target.view)
	{
		_target.view.transform = CGAffineTransformIdentity;
	}
	
	if(_currentStartDelay < _startDelay)
	{
		_currentStartDelay += delta;
		
		if(_currentStartDelay > _startDelay)
		{
			delta = _currentStartDelay - _startDelay;
			_currentStartDelay = _startDelay;
			
			for(BBasicAction* anim in _actions)
			{
				[anim update: delta];
			}
			
			[_target update: delta];
		}
	}
	else
	{
		for(BBasicAction* anim in _actions)
		{
			[anim update: delta];
		}
		
		[_target update: delta];
	}
	

}

- (void)reset
{	
	if(_target.view)
	{
		_target.view.transform = CGAffineTransformIdentity;
	}
	
	for(BBasicAction* anim in _actions)
	{
		[anim reset];
	}
	
	[_target reset];
	
	_currentStartDelay = 0.0f;
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	BAnimation* instance = [[[BAnimation alloc] init] autorelease];
	
	xmlChar* delayProp = xmlGetProp(node, (xmlChar*)"start-delay");
	
	if(delayProp)
	{
		NSString* delayString = [NSString stringWithUTF8String: (const char*)delayProp];
		instance->_startDelay = [delayString floatValue];
	}
	
	xmlChar* centerProp = xmlGetProp(node, (xmlChar*)"center");
	
	if(centerProp)
	{
		NSString* centerStr = [NSString stringWithUTF8String: (const char*)centerProp];
		instance->_center = CGPointFromString(centerStr);
	}
	
	
	xmlChar* sizeProp = xmlGetProp(node, (xmlChar*)"size");
	
	if(sizeProp)
	{
		NSString* sizeStr = [NSString stringWithUTF8String: (const char*)sizeProp];
		instance->_size = CGSizeFromString(sizeStr);
	}
	
	
	xmlNodePtr dataNode = node->children;
	
	while (dataNode)
	{
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"target") && dataNode->children && dataNode->children->content)
		{
			BAnimationTarget* target = [BAnimationTarget deserialize: dataNode];
			
			if(!target)
			{
				return nil;
			}
			
			instance->_target = [target retain];
		}
		
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"actions"))
		{
			xmlNodePtr animNode = dataNode->children;
			
			while (animNode)
			{
				if(!xmlStrcmp(animNode->name, (xmlChar*)"action"))
				{
					BBasicAction* anim = [BBasicAction deserialize: animNode];
					
					if(anim)
					{
						[instance->_actions addObject: anim];
					}
				}
				
				animNode = animNode->next;
			}
		}
		
		dataNode = dataNode->next;
	}
	
	return instance;
}

@end
