//
//  BControlInfo.m
//  books
//
//  Created by Dmitriy Panin on 10.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BControlInfo.h"
#import "BToolFunctions.h"

@implementation BControlInfo

@synthesize type = _type;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize disabledImage = _disabledImage;
@synthesize argument = _argument;
@synthesize checkmark = _checkmark;
@synthesize dragable = _dragable;

- (void)dealloc
{
	[_argument release];
	[_normalImage release];
	[_highlightedImage release];
	[_disabledImage release];
	[_centersDict release];
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		_centersDict = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	xmlChar* typeProp = xmlGetProp(node, (xmlChar*)"type");
	
	if(!typeProp)
	{
		return nil;
	}
	
	NSString* typeStr = [NSString stringWithUTF8String: (const char*)typeProp];
	
	BControlType typeVal;
	
	if([typeStr isEqualToString:@"prev-page"])
	{
		typeVal = kControlTypePrevPage;
	}
	else if([typeStr isEqualToString:@"next-page"])
	{
		typeVal = kControlTypeNextPage;
	}
	else if([typeStr isEqualToString:@"bookmarks"])
	{
		typeVal = kControlTypeBookmarks;
	}
	else if([typeStr isEqualToString:@"add-bookmark"])
	{
		typeVal = kControlTypeAddBookmark;
	}
	else if([typeStr isEqualToString:@"play-sound"])
	{
		typeVal = kControlTypePlaySound;
	}
	else if([typeStr isEqualToString:@"stop-sound"])
	{
		typeVal = kControlTypeStopSound;
	}
	else if([typeStr isEqualToString:@"toggle-player"])
	{
		typeVal = kControlTypeTogglePlayer;
	}
	else if([typeStr isEqualToString:@"search"])
	{
		typeVal = kControlTypeSearch;
	}
	else if([typeStr isEqualToString:@"page-link"])
	{
		typeVal = kControlTypePageLink;
	}
	else if([typeStr isEqualToString:@"toggle-animations"])
	{
		typeVal = kControlTypeToggleAnimations;
	}
	else
	{
		return nil;
	}
	
	BControlInfo* instance = [[[BControlInfo alloc] init] autorelease];
	instance->_type = typeVal;
	
	xmlChar* checkmarkProp = xmlGetProp(node, (xmlChar*)"checkmark");
	
	if(checkmarkProp && !xmlStrcmp(checkmarkProp, (xmlChar*)"true"))
	{
		instance.checkmark = YES;
	}

	xmlChar* dragableProp = xmlGetProp(node, (xmlChar*)"dragable");
	
	if(dragableProp && !xmlStrcmp(dragableProp, (xmlChar*)"true"))
	{
		instance.dragable = YES;
	}
	
	xmlNodePtr dataNode = node->children;
	
	while (dataNode) 
	{
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"center"))
		{
			CGPoint center = CGPointZero;
			
			xmlNodePtr centerNode = dataNode->children;
			
			while (centerNode)
			{
				if(!xmlStrcmp(centerNode->name, (xmlChar*)"x") && centerNode->children && centerNode->children->content)
				{
					NSString* tmp = [NSString stringWithUTF8String: (const char*)centerNode->children->content];
					center.x = [tmp floatValue];
				}
				
				if(!xmlStrcmp(centerNode->name, (xmlChar*)"y") && centerNode->children && centerNode->children->content)
				{
					NSString* tmp = [NSString stringWithUTF8String: (const char*)centerNode->children->content];
					center.y = [tmp floatValue];
				}
				
				centerNode = centerNode->next;
			}
			
			xmlChar* centerTypeChr = xmlGetProp(dataNode, (xmlChar*)"state");
			BControlState typeOfCenter = -1;
			
			if(centerTypeChr)
			{
				NSString* centerType = [NSString stringWithUTF8String: (const char*)centerTypeChr];
				
				if([centerType isEqualToString: @"highlighted"])
				{
					typeOfCenter = kControlStateHighlighted;
				}
				else if([centerType isEqualToString: @"disabled"])
				{
					typeOfCenter = kControlStateDisabled;
				}
			}
			else
			{
				typeOfCenter = kControlStateNormal;
			}
			
		
			if(typeOfCenter == -1)
			{
				NSLog(@"WARNING %s: Unknown type of the center %s. Ignoing", __FUNCTION__, centerTypeChr);
				continue;
			}
			
			[instance->_centersDict setObject:[NSValue valueWithCGPoint: center] forKey: [NSNumber numberWithInt: typeOfCenter]];
		}
		
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"image") && dataNode->children && dataNode->children->content)
		{
			NSString* pathTemplate = [NSString stringWithUTF8String: (const char*)dataNode->children->content];
			NSString* path = pathOfResourceWithTemplate(pathTemplate);
			
			UIImage* img = [UIImage imageWithContentsOfFile:path];			
			instance.normalImage = img;
		}
		
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"highlighted-image") && dataNode->children && dataNode->children->content)
		{
			NSString* pathTemplate = [NSString stringWithUTF8String: (const char*)dataNode->children->content];
			NSString* path = pathOfResourceWithTemplate(pathTemplate);
			
			UIImage* img = [UIImage imageWithContentsOfFile:path];			
			instance.highlightedImage = img;
		}
		
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"disabled-image") && dataNode->children && dataNode->children->content)
		{
			NSString* pathTemplate = [NSString stringWithUTF8String: (const char*)dataNode->children->content];
			NSString* path = pathOfResourceWithTemplate(pathTemplate);
			
			UIImage* img = [UIImage imageWithContentsOfFile:path];			
			instance.disabledImage = img;
		}
		
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"arg") && dataNode->children && dataNode->children->content)
		{
			if(instance.type == kControlTypePageLink)
			{			
				NSString* str = [NSString stringWithUTF8String: (const char*)dataNode->children->content];
				instance.argument = str;
			}
			else
			{
				NSMutableArray*	listOfAnimations = [[[NSMutableArray alloc] initWithCapacity: 0] autorelease];
				instance.argument = listOfAnimations;
				
				xmlNodePtr animationsNode = dataNode->children;
				
				while (animationsNode)
				{
					if(!xmlStrcmp(animationsNode->name, (xmlChar*)"animation") && dataNode->children && dataNode->children->content)
					{
						NSString* str = [NSString stringWithUTF8String: (const char*)animationsNode->children->content];
						[listOfAnimations addObject: str];
					}
					
					animationsNode = animationsNode->next;
				}
			}
		}
		
		
		dataNode = dataNode->next;
	}
	
	CGPoint defaultCenter = CGPointZero;
	
	if([instance->_centersDict objectForKey: [NSNumber numberWithInt: kControlStateNormal]])
	{
		defaultCenter = [[instance->_centersDict objectForKey: [NSNumber numberWithInt: kControlStateNormal]] CGPointValue];
	}
	else
	{
		NSNumber* defaultKey = [[instance->_centersDict allKeys] objectAtIndex: 0];
		
		defaultCenter = [[instance->_centersDict objectForKey: defaultKey] CGPointValue];
	}
	
	for(int i = 0; i <= kControlStateDisabled; i++)
	{
		if(![instance->_centersDict  objectForKey: [NSNumber numberWithInt: i]])
		{
			[instance->_centersDict setObject:[NSValue valueWithCGPoint: defaultCenter] forKey: [NSNumber numberWithInt: i]];
		}
	}
	
	return instance;
}

- (CGPoint)centerForState:(BControlState)state
{
	NSValue* val = [_centersDict objectForKey: [NSNumber numberWithInt: state]];
	CGPoint point = [val CGPointValue];
	return point;
}

- (void)setCenter:(CGPoint)center forState:(BControlState)state
{
	[_centersDict setObject: [NSValue valueWithCGPoint:center] forKey: [NSNumber numberWithInt: state]];
}
 
@end
