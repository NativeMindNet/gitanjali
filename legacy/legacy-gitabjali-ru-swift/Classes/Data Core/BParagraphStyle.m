//
//  BParagraphStyle.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BParagraphStyle.h"
#import "UIColor+StringExtension.h"

@implementation BParagraphStyle

@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
@synthesize textAlignment = _textAlignment;
@synthesize textColor = _textColor;
@synthesize backgroundColor = _backgroundColor;

- (void)dealloc
{
	self.fontName = nil;
	self.textColor = nil;
	self.backgroundColor = nil;
	[super dealloc];
}

- (id)init
{
	return [self initDefaultTextStyle];
}

- (id)initDefaultTextStyle
{
	if(self = [super init])
	{
		self.fontName = @"MurariChandUni";
		self.textColor = [UIColor blackColor];
		self.fontSize = 18.0f;
		self.textAlignment = UITextAlignmentLeft;
 	}

	return self;
}

- (id)initDefaultHeaderStyle
{
	if(self = [super init])
	{
		self.fontName = @"MurariChandUni";
		self.textColor = [UIColor blackColor];
		self.fontSize = 22.0f;
		self.textAlignment = UITextAlignmentCenter;
 	}
	
	return self;	
}

+ (id)deserialize:(xmlNodePtr)node
{	
	if(!node)
	{
		return nil;
	}
	
	BParagraphStyle* instance = [[[BParagraphStyle alloc] init] autorelease];
	
	xmlChar* prop = NULL;
	
	//font name
	prop = xmlGetProp(node, (xmlChar*)"font-name");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		instance.fontName = propStr;
		xmlFree(prop);
	}
	
	//font size
	prop = xmlGetProp(node, (xmlChar*)"font-size");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		instance.fontSize = [propStr floatValue];
		xmlFree(prop);
	}
	
	//alignment
	prop = xmlGetProp(node, (xmlChar*)"text-alignment");
	
	if(prop)
	{
		if(!xmlStrcmp(prop, (xmlChar*)"center"))
		{
			instance.textAlignment = UITextAlignmentCenter;
		}
		
		if(!xmlStrcmp(prop, (xmlChar*)"right"))
		{
			instance.textAlignment = UITextAlignmentRight;
		}
		
		xmlFree(prop);
	}
	
	//font color
	prop = xmlGetProp(node, (xmlChar*)"text-color");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		instance.textColor = [UIColor colorWithString: propStr];
		xmlFree(prop);
	}
	
	//background color
	prop = xmlGetProp(node, (xmlChar*)"background-color");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		instance.backgroundColor = [UIColor colorWithString: propStr];
		xmlFree(prop);
	}
	
	return instance;
}

- (BOOL)loadAdditionalItemsFromNode:(xmlNodePtr)node
{
	BOOL res = NO;
	
	xmlChar* prop = NULL;
	
	//font name
	prop = xmlGetProp(node, (xmlChar*)"font-name");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		self.fontName = propStr;
		res = YES;
		xmlFree(prop);
	}
	
	//font size
	prop = xmlGetProp(node, (xmlChar*)"font-size");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		self.fontSize = [propStr floatValue];
		res = YES;
		xmlFree(prop);
	}
	
	//alignment
	prop = xmlGetProp(node, (xmlChar*)"text-alignment");
	
	if(prop)
	{
		if(!xmlStrcmp(prop, (xmlChar*)"center"))
		{
			self.textAlignment = UITextAlignmentCenter;
		}
		
		if(!xmlStrcmp(prop, (xmlChar*)"right"))
		{
			self.textAlignment = UITextAlignmentRight;
		}
		
		res = YES;
		xmlFree(prop);
	}
	
	//font color
	prop = xmlGetProp(node, (xmlChar*)"text-color");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		self.textColor = [UIColor colorWithString: propStr];
		xmlFree(prop);
		res = YES;
	}
	
	//background color
	prop = xmlGetProp(node, (xmlChar*)"background-color");
	
	if(prop)
	{
		NSString* propStr = [NSString stringWithUTF8String: (const char*)prop];
		self.backgroundColor = [UIColor colorWithString: propStr];
		xmlFree(prop);
		res = YES;
	}
	
	
	
	return res;
}

@end
