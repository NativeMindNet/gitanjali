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
@synthesize center = _center;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize disabledImage = _disabledImage;
@synthesize argument = _argument;

- (void)dealloc
{
	[_argument release];
	[_normalImage release];
	[_highlightedImage release];
	[_disabledImage release];
	[super dealloc];
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
	else
	{
		return nil;
	}
	
	BControlInfo* instance = [[[BControlInfo alloc] init] autorelease];
	instance.type = typeVal;
	
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
			
			instance.center = center;
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
			NSString* str = [NSString stringWithUTF8String: (const char*)dataNode->children->content];
			instance.argument = str;
		}
		
		dataNode = dataNode->next;
	}
	
	return instance;
}
 
@end
