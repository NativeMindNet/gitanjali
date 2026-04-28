//
//  BBookSection.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBookSection.h"
#import "BBookBody.h"
#import "BParagraph.h"
#import "BBookPage.h"
#import "BToolFunctions.h"
#import "BAnimation.h"
#import "UIColor+StringExtension.h"
#import "BControlInfo.h"

@interface BBookSection(Private)
- (void)_addParagraph:(BParagraph*)p;
@end


@implementation BBookSection

@synthesize title = _title;
@synthesize content = _content;
@synthesize bookBody = _bookBody;
@synthesize contentTitle = _contentTitle;

- (void)dealloc
{
	[_title release];
	[_content release];
	[_contentTitle release];
	
	_bookBody = nil;
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		_content = [[NSMutableArray alloc] init];
	}
	
	return self;
}

+ (id)deserialize:(xmlNodePtr)node withBookBody:(BBookBody*)bookBody
{
	if(!node)
	{
		return nil;
	}
	
	BBookSection* instance = [[[BBookSection alloc] init] autorelease];
	instance->_bookBody = bookBody;
	
	if(!instance.bookBody.pages.count)
	{
		[instance.bookBody createEmptyPage];
	}
	
	[[instance.bookBody.pages lastObject] addSection: instance];
	
	xmlNodePtr childNode = node->children;
	
	while (childNode)
	{
		if(!xmlStrcmp(childNode->name, (xmlChar*)"title"))
		{
			xmlNodePtr pNode = childNode->children;
			
			while (pNode) 
			{
				if(!xmlStrcmp(pNode->name, (xmlChar*)"p"))
				{
					BParagraph* p = [BParagraph deserialize:pNode withPage: [bookBody.pages lastObject] andSection: instance header: YES];
					
					instance->_title = [p retain];
					
					[instance _addParagraph: p];
					
				}
				
				pNode = pNode->next;
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"content-title"))
		{
			xmlNodePtr pNode = childNode->children;
			
			while (pNode) 
			{
				if(!xmlStrcmp(pNode->name, (xmlChar*)"p"))
				{
					BParagraph* p = [BParagraph deserialize:pNode withPage: [bookBody.pages lastObject] andSection: instance header: YES];
					
					instance->_contentTitle = [p retain];
				}
				
				pNode = pNode->next;
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"p"))
		{
			BParagraph* p = [BParagraph deserialize:childNode withPage: [bookBody.pages lastObject] andSection: instance header: NO];
			
			[instance _addParagraph: p];
			[instance->_content addObject: p];
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"section"))
		{
			BBookSection* section = [BBookSection deserialize:childNode withBookBody: bookBody];
			
			if(section)
			{
				[instance->_content addObject: section];
			}
		}
		
		if(!xmlStrcmp(childNode->name, (xmlChar*)"page"))
		{
			[[instance.bookBody.pages lastObject] addSection: instance];
			
			xmlNodePtr pageNode = childNode->children;
			
			while (pageNode)
			{
				if(!xmlStrcmp(pageNode->name, (xmlChar*)"audio") && pageNode->children && pageNode->children->content)
				{
					NSString* fullPath = pathOfResourceWithTemplate([NSString stringWithUTF8String: (const char*)pageNode->children->content]);
					
					if([[NSFileManager defaultManager] fileExistsAtPath: fullPath])
					{
						((BBookPage*)[instance.bookBody.pages lastObject]).soundURL = [NSURL fileURLWithPath: fullPath];
						
						xmlChar* autiploayProp = xmlGetProp(pageNode, (xmlChar*)"autoplay");
						
						if(autiploayProp && !xmlStrcmp(autiploayProp, (xmlChar*)"true"))
						{
							((BBookPage*)[instance.bookBody.pages lastObject]).autoplaySound = YES;
						}
						
						xmlChar* loopProp = xmlGetProp(pageNode, (xmlChar*)"loop");
						
						if(loopProp && !xmlStrcmp(loopProp, (xmlChar*)"true"))
						{
							((BBookPage*)[instance.bookBody.pages lastObject]).loopSound = YES;
						}
					}
				}
				
				if(!xmlStrcmp(pageNode->name, (xmlChar*)"comments"))
				{
					xmlNodePtr subnode = pageNode->children;
					
					while (subnode) 
					{
						if(!xmlStrcmp(subnode->name, (xmlChar*)"p"))
						{
							BBookPage* lastPage = [instance.bookBody.pages lastObject];
							BParagraph* paragraph = [BParagraph deserialize:subnode withPage:lastPage andSection:instance header: YES];
							lastPage.comments = paragraph;  
						}
						
						subnode = subnode->next;
					}
			
				}
				
				if(!xmlStrcmp(pageNode->name, (xmlChar*)"background"))
				{
					xmlChar* colorProp = xmlGetProp(pageNode, (xmlChar*)"color");
					
					if(colorProp)
					{
						NSString* colorStr = [NSString stringWithUTF8String: (const char*)colorProp];
						((BBookPage*)[instance.bookBody.pages lastObject]).backgroundColor = [UIColor colorWithString: colorStr];
					}
					
					xmlChar* backgroundImageProp = xmlGetProp(pageNode, (xmlChar*)"image");
					
					if(backgroundImageProp)
					{
						NSString* path = [NSString stringWithUTF8String: (const char*)backgroundImageProp];
						NSString* fullPath = pathOfResourceWithTemplate(path);
						
						((BBookPage*)[instance.bookBody.pages lastObject]).backgroundImagePath = fullPath;
					}
					
					//animation deserialization
					
					xmlNodePtr animationNode = pageNode->children;
					
					while (animationNode) 
					{
						if(!xmlStrcmp(animationNode->name, (xmlChar*)"animation"))
						{
							BAnimation* animation = [BAnimation deserialize: animationNode];
							
							if(animation)
							{
								[((BBookPage*)[instance.bookBody.pages lastObject]) addAnimation: animation];
							}
						}
						
						animationNode = animationNode->next;
					}
					

				}
				
				if(!xmlStrcmp(pageNode->name, (xmlChar*)"show-number") && pageNode->children && pageNode->children->content)
				{
					NSString* str =[NSString stringWithUTF8String: (const char*)pageNode->children->content];
				
					((BBookPage*)[instance.bookBody.pages lastObject]).showNumber = (BOOL)[str intValue];
				}
				
				if(!xmlStrcmp(pageNode->name, (xmlChar*)"controls"))
				{
					xmlNodePtr controlNode = pageNode->children;
					
					while (controlNode) 
					{
						if(!xmlStrcmp(controlNode->name, (xmlChar*)"control"))
						{
							BControlInfo* controlInfo = [BControlInfo deserialize: controlNode];
							
							if(controlInfo)
							{
								[[((BBookPage*)[instance.bookBody.pages lastObject]) pageControls] addObject: controlInfo];
							}
						}
						
						controlNode = controlNode->next;
					}
				}
				
				pageNode = pageNode->next;
			}
			
			[instance.bookBody createEmptyPage];
		}
		
		childNode = childNode->next;
	}
	
	if(!instance->_contentTitle)
	{
		instance->_contentTitle = [instance->_title retain];
	}
	
	return instance;
}

- (void)_addParagraph:(BParagraph*)p
{
	[[self.bookBody.pages lastObject] addParagraph: p];
}


@end
