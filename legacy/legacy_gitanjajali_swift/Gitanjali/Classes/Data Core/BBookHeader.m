//
//  BBookHeader.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBookHeader.h"


@implementation BBookHeader

@synthesize identifier = _identifier;
@synthesize authors = _authors;
@synthesize translators = _translators;
@synthesize title = _title;
@synthesize language = _language;
@synthesize sourceLanguage = _sourceLanguage;
@synthesize isbn = _isbn;
@synthesize genre = _genre;
@synthesize publisherInfo = _publisherInfo;
@synthesize orientation = _orientation;
@synthesize controls = _controls;

- (void)dealloc
{
	[_authors release];
	[_translators release];
	[_controls release];
	
	self.identifier = nil;
	self.title = nil;
	self.language = nil;
	self.sourceLanguage = nil;
	self.isbn = nil;
	self.genre = nil;
	self.publisherInfo = nil;
	
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		_authors = [[NSMutableArray alloc] init];
		_translators = [[NSMutableArray alloc] init];
		_controls = [[NSMutableArray alloc] init];
		_orientation = kBookOrientationPortrait;
	}
	return self;
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	BBookHeader* instance = [[[BBookHeader alloc] init] autorelease];
	
	xmlNodePtr childNode = node->children;
	
	while (childNode)
	{
		if(!xmlStrcmp(childNode->name, (xmlChar*)"id") && childNode->children && childNode->children->content)
		{
			instance.identifier = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"book-title") && childNode->children && childNode->children->content)
		{
			instance.title = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"lang") && childNode->children && childNode->children->content)
		{
			instance.language = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"src-lang") && childNode->children && childNode->children->content)
		{
			instance.sourceLanguage = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"isbn") && childNode->children && childNode->children->content)
		{
			instance.isbn = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"genre") && childNode->children && childNode->children->content)
		{
			instance.genre = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"author"))
		{
			BPerson* author = [BPerson deserialize: childNode];
			
			if(author)
			{
				[instance.authors addObject: author];
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"translator"))
		{
			BPerson* trans = [BPerson deserialize: childNode];
			
			if(trans)
			{
				[instance.translators addObject: trans];
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"publish-info"))
		{
			BPublishInfo* publishInfo = [BPublishInfo deserialize: childNode];
			instance.publisherInfo = publishInfo;
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"orientation") && childNode->children && childNode->children->content)
		{
			NSString* temp = [[[NSString alloc] initWithUTF8String: (const char*)childNode->children->content]  autorelease];
			
			if([temp caseInsensitiveCompare: @"landscape"] == NSOrderedSame)
			{
				instance.orientation = kBookOrientationLandscape;
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"controls"))
		{
			xmlNodePtr controlNode = childNode->children;
			
			while (controlNode) 
			{
				if(!xmlStrcmp(controlNode->name, (xmlChar*)"control"))
				{
					BControlInfo* controlInfo = [BControlInfo deserialize: controlNode];
					
					if(controlInfo)
					{
						[instance.controls addObject: controlInfo];
					}
				}
				
				controlNode = controlNode->next;
			}
		}
		
		childNode = childNode->next;
	}
	
	return instance;
}

@end
