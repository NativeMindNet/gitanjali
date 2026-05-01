//
//  BBookmark.m
//  books
//
//  Created by Dmitry Panin on 01.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBookmark.h"

@implementation BBookmark

@synthesize page = _pageRef;

- (void)dealloc
{
	self.page = nil;
	[super dealloc];
}

@end
