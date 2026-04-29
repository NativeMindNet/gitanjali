//
//  BBookBody.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBookBody.h"

@implementation BBookBody

@synthesize pages = _pages;
@synthesize rootSection = _rootSection;
@synthesize stylesStorage = _stylesStorage;

- (void)dealloc
{
	[_stylesStorage release];
	[_pages release];
	[_rootSection release];
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		_stylesStorage = [[BParagraphStylesStorage alloc] init];
		_pages = [[NSMutableArray alloc] init];
	}
	
	return self;
}

+ (id)deserialize:(xmlNodePtr)node
{
	if(!node)
	{
		return nil;
	}
	
	BBookBody* instance = [[[BBookBody alloc] init] autorelease];
	
	xmlNodePtr childNode = node->children;
	
	while (childNode)
	{
		if(!xmlStrcmp(childNode->name, (xmlChar*)"styles"))
		{
			xmlNodePtr stylesNode = childNode->children;
			
			while (stylesNode) 
			{
				if(!xmlStrcmp(stylesNode->name, (xmlChar*)"style"))
				{
					xmlChar* name = xmlGetProp(stylesNode,(xmlChar*)"name");
					
					if(name && xmlStrlen(name))
					{
						BParagraphStyle* style = [BParagraphStyle deserialize: stylesNode];
						
						if(style)
						{
							[instance->_stylesStorage setStyle:style forName: [NSString stringWithUTF8String: (const char*)name]];
						}
						
						xmlFree(name);
					}
				}
				
				stylesNode = stylesNode->next;
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"section"))
		{
			instance->_rootSection = [[BBookSection deserialize: childNode withBookBody: instance] retain];
		}
				
		childNode = childNode->next;
	}
	
	if(instance->_pages.count)
	{
		BOOL pageEmpty = YES;
		
		BBookPage* lastPage = [instance->_pages lastObject];
		
		if(lastPage.paragraphs.count)
		{
			pageEmpty = NO;
		}
		
		if(lastPage.soundURL)
		{
			pageEmpty = NO;
		}
		
		if(lastPage.backgroundImagePath || lastPage.animations.count)
		{
			pageEmpty = NO;
		}
		
		if(pageEmpty)
		{
			[instance->_pages removeLastObject];
		}
	}
	
	return instance;
}

- (void)createEmptyPage
{
	BBookPage* page = [[BBookPage alloc] init];
	[_pages addObject: page];
	page.number = _pages.count;
	page.bookBody = self;
	[page release];
}


- (NSArray*)searchForPhrase:(NSString*)phrase
{
	NSMutableArray* res = [NSMutableArray arrayWithCapacity: 0];
	
	if(!phrase)
	{
		return nil;
	}
	
	for(BBookPage* page in self.pages)
	{
	
		for(BParagraph* p in page.paragraphs)
		{
			if([p.text rangeOfString:phrase options: NSCaseInsensitiveSearch].location != NSNotFound)
			{
				[res addObject: page];
				break;
			}
		}	
	}
	
	return res;
}

@end
