//
//  BParagraph.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BParagraph.h"
#import "BBookSection.h"
#import "BBookPage.h"
#import "BBookBody.h"
#import "BParagraphStylesStorage.h"
#import "BToolFunctions.h"


@implementation BParagraph

@synthesize	text = _text;
@synthesize	styleName = _styleName;
@synthesize	page = _page;
@synthesize	section = _section;
@synthesize largeCapitalLetter = _largeCaptialLetter;
@synthesize hidden = _hidden;

- (void)dealloc
{
	self.text = nil;
	self.styleName = nil;
	self.page = nil;
	self.section = nil;
	self.largeCapitalLetter = nil;
	[super dealloc];
}

+ (id)deserialize:(xmlNodePtr)node withPage:(BBookPage*)page andSection:(BBookSection*)section header:(BOOL)header
{
	if(!node)
	{
		return nil;
	}
	
	BParagraph* instance = [[[BParagraph alloc] init] autorelease];
	instance.page = page;
	instance.section = section;
	
	if(node && node->children && node->children->content)
	{
		instance.text = [NSString stringWithUTF8String: (const char*)node->children->content];
	}
	
	if(header)
	{
		instance.styleName = [instance.page.bookBody.stylesStorage nameOfTheDefaultHeaderStyle];
	}
	else
	{
		instance.styleName = [instance.page.bookBody.stylesStorage nameOfTheDefaultStyle];	
	}

	xmlChar* styleName = xmlGetProp(node, (xmlChar*)"style");
	
	if(styleName)
	{
		instance.styleName = [NSString stringWithUTF8String: (const char*)styleName];
		
		xmlFree(styleName);
	}
	
	//find for additional styles props
	
	BParagraphStyle* s = nil;
	
	if(header)
	{
		s = [[BParagraphStyle alloc] initDefaultHeaderStyle];
	}
	else 
	{
		s = [[BParagraphStyle alloc] initDefaultTextStyle];
	}
	
	BOOL additionalStylePresent = [s loadAdditionalItemsFromNode:node];
	
	if(additionalStylePresent)
	{
		instance.styleName = [instance.page.bookBody.stylesStorage generateNameForUnnamedStyle];
		[instance.page.bookBody.stylesStorage setStyle:s  forName: instance.styleName];
	}
	 
	[s release];
	
	xmlChar* largeCapitalLetter = xmlGetProp(node, (xmlChar*)"large-capital-letter");
	
	if(largeCapitalLetter)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)largeCapitalLetter];
		str = pathOfResourceWithTemplate(str);

		if([[NSFileManager defaultManager] isReadableFileAtPath: str])
		{
			instance.largeCapitalLetter = str;
		}
		
		xmlFree(largeCapitalLetter);
	}
	
	xmlChar*  hiddenProp = xmlGetProp(node, (xmlChar*)"hidden");
	
	if(hiddenProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)hiddenProp];
		
		if([str caseInsensitiveCompare: @"true"] == NSOrderedSame ||
		   [str caseInsensitiveCompare: @"1"] == NSOrderedSame)
		{
			instance.hidden = YES;
		}
		
		xmlFree(hiddenProp);
	}
	
	return instance;
}

@end
