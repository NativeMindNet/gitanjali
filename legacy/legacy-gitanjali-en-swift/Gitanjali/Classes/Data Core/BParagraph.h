//
//  BParagraph.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDefines.h"
#import <libxml/xmlmemory.h>
#import <libxml/parser.h>

@class BBookPage;
@class BBookSection;

@interface BParagraph : NSObject 
{
	NSString*		_text;
	NSString*		_styleName;
	BBookPage*		_page;
	BBookSection*	_section;
	NSString*		_largeCaptialLetter;
	BOOL			_hidden;
}

@property(copy)		NSString*		text;
@property(copy)		NSString*		styleName;
@property(copy)		NSString*		largeCapitalLetter;
@property(assign)	BBookPage*		page;
@property(assign)	BBookSection*	section;
@property(assign)	BOOL			hidden;

+ (id)deserialize:(xmlNodePtr)node withPage:(BBookPage*)page andSection:(BBookSection*)section header:(BOOL)header;

@end
