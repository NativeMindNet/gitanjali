//
//  BBookPage.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBookPage.h"
#import "BParagraph.h"
#import "BBookBody.h"
#import "BBookSection.h"
#import "BAnimation.h"

@implementation BBookPage

@synthesize paragraphs = _paragraphs;
@synthesize sections = _sections;
@synthesize number = _number;
@synthesize bookBody = _bookBody;
@synthesize soundURL = _soundURL;
@synthesize showNumber = _showNumber;
@synthesize backgroundImagePath = _backgroundImagePath;
@synthesize backgroundColor = _backgroundColor;
@synthesize animations = _animations;
@synthesize comments = _comments;
@synthesize autoplaySound = _autoplaySound;
@synthesize loopSound = _loopSound;
@synthesize pageControls = _pageControls;

- (void)dealloc
{
	self.backgroundColor = nil;
	self.comments = nil;
	[_pageControls release];
	[_paragraphs release];
	[_sections release];
	[_soundURL release];
	[_backgroundColor release];
	[_backgroundImagePath release];
	[_animations release];
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		self.showNumber = YES;
		self.backgroundColor = [UIColor whiteColor];
		_pageControls = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addParagraph:(BParagraph*)paragraph
{
	if(!_paragraphs)
	{
		_paragraphs = [[NSMutableArray alloc] init];
	}
	
	[_paragraphs addObject: paragraph];
}

- (void)addSection:(BBookSection*)section
{
	if(!_sections)
	{
		_sections = [[NSMutableArray alloc] init];
	}
	
	[_sections addObject: section];
}

- (void)addAnimation:(BAnimation*)animation
{
	if(!_animations)
	{
		_animations = [[NSMutableArray alloc] init];	
	}

	[_animations addObject: animation];
}

@end
