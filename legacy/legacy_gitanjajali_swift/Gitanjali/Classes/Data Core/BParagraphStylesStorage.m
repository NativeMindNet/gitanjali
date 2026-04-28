//
//  BParagraphStylesStorage.m
//  books
//
//  Created by Dmitry Panin on 24.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BParagraphStylesStorage.h"

@implementation BParagraphStylesStorage

- (void)dealloc
{
	[_storage release];
	[super dealloc];
}

- (id)init
{
	if(self = [super init])
	{
		_storage = [[NSMutableDictionary alloc] init];
		
		[_storage setObject: [[[BParagraphStyle alloc] initDefaultTextStyle] autorelease]
					 forKey: [self nameOfTheDefaultStyle]];
		
		[_storage setObject: [[[BParagraphStyle alloc] initDefaultHeaderStyle] autorelease]
					 forKey: [self nameOfTheDefaultHeaderStyle]];
	}
	
	return self;
}

- (BParagraphStyle*)styleForName:(NSString*)name
{
	BParagraphStyle* style = [_storage objectForKey: name];
	
	if(!style)
	{
		style = [_storage objectForKey: [self nameOfTheDefaultStyle]];
	}
	
	return style;
}

- (void)setStyle:(BParagraphStyle*)style forName:(NSString*)name
{
	[_storage setObject: style forKey: name];
}

- (NSString*)nameOfTheDefaultStyle
{
	return @"default-text-style";
}

- (NSString*)nameOfTheDefaultHeaderStyle
{
	return @"default-header-style";
}

- (NSString*)generateNameForUnnamedStyle
{
	return [NSString stringWithFormat: @"no-name-style-%d", _counter++];
}

@end
