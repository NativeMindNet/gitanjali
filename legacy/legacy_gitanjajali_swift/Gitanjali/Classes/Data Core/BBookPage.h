//
//  BBookPage.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDefines.h"

@class BParagraph;
@class BBookBody;
@class BBookSection;
@class BAnimation;

@interface BBookPage : NSObject
{
	NSMutableArray*		_paragraphs;
	NSMutableArray*		_sections;
	int					_number;
	BBookBody*			_bookBody;
	NSURL*				_soundURL;
	BOOL				_showNumber;
	
	NSString*			_backgroundImagePath;	
	UIColor*			_backgroundColor;
	
	NSMutableArray*		_animations;
	
	BParagraph*			_comments;
	
	BOOL				_autoplaySound;
	BOOL				_loopSound;
	
	NSMutableArray*		_pageControls;
}

@property(readonly)	NSArray*			paragraphs;
@property(readonly)	NSArray*			sections;
@property(assign)	int					number;
@property(assign)	BBookBody*			bookBody;
@property(retain)	NSURL*				soundURL;
@property(assign)	BOOL				autoplaySound;
@property(assign)	BOOL				loopSound;
@property(assign)	BOOL				showNumber;

@property(copy)		NSString*			backgroundImagePath;
@property(retain)	UIColor*			backgroundColor;
@property(retain)	BParagraph*			comments;

@property(readonly)	NSArray*			animations;
@property(readonly)	NSMutableArray*		pageControls;

- (void)addParagraph:(BParagraph*)paragraph;
- (void)addSection:(BBookSection*)section;
- (void)addAnimation:(BAnimation*)animation;

@end
