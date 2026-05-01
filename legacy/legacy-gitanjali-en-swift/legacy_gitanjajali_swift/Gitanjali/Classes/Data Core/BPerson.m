//
//  BPerson.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BPerson.h"

@implementation BPerson

@synthesize firstName = _firstName;
@synthesize middleName = _middleName;
@synthesize lastName = _lastName;
@synthesize nickname = _nickname;
@synthesize email = _email;

- (void)dealloc
{
	self.firstName = nil;
	self.middleName = nil;
	self.lastName = nil;
	self.nickname = nil;
	self.email = nil;
	[super dealloc];
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	BPerson* instance = [[[BPerson alloc] init] autorelease];
	
	xmlNodePtr childNode = node->children;
	
	while (childNode)
	{
		if(!xmlStrcmp(childNode->name, (xmlChar*)"first-name") && childNode->children && childNode->children->content)
		{
			instance.firstName = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"last-name") && childNode->children && childNode->children->content)
		{
			instance.lastName = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"middle-name") && childNode->children && childNode->children->content)
		{
			instance.middleName = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}

		if(!xmlStrcmp(childNode->name, (xmlChar*)"nickname") && childNode->children && childNode->children->content)
		{
			instance.nickname = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"email") && childNode->children && childNode->children->content)
		{
			instance.email = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		childNode = childNode->next;
	}
	
	return instance;
}

@end
