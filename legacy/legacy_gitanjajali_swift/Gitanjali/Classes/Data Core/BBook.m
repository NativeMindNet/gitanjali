//
//  BBook.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBook.h"

@implementation BBook

@synthesize header = _header;
@synthesize body = _body;

- (void)dealloc
{
	[_header release];
	[_body release];
	[super dealloc];
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	xmlChar* version = xmlGetProp(node, (xmlChar*)"version");
	
	if(!version || xmlStrcmp(version, (xmlChar*)[BBOOK_FORMAT_VERSION UTF8String]))
	{
		return nil;
	}
	
	BBook* instance = [[[BBook alloc] init] autorelease];
	
	xmlNodePtr childNode = node->children;
	
	while (childNode)
	{
		if(!xmlStrcmp(childNode->name, (xmlChar*)"head"))
		{			
			instance->_header = [[BBookHeader deserialize: childNode] retain];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"body"))
		{
			instance->_body = [[BBookBody deserialize: childNode] retain];
		}
			
		childNode = childNode->next;
	}
	
	return instance;
}

@end
