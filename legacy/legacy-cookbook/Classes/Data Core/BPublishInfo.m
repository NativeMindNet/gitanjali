//
//  BPublishInfo.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BPublishInfo.h"

@implementation BPublishInfo

@synthesize publisher = _publisher;
@synthesize city = _city;
@synthesize year = _year;

- (void)dealloc
{
	self.publisher = nil;
	self.city = nil;
	self.year = nil;
	[super dealloc];
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	BPublishInfo* instance = [[[BPublishInfo alloc] init] autorelease];
	
	xmlNodePtr childNode = node->children;
	
	while (childNode)
	{
		if(!xmlStrcmp(childNode->name, (xmlChar*)"publisher") && childNode->children && childNode->children->content)
		{
			instance.publisher = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"city") && childNode->children && childNode->children->content)
		{
			instance.city = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"year") && childNode->children && childNode->children->content)
		{
			instance.year = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		childNode = childNode->next;
	}
	
	return instance;
}

@end
