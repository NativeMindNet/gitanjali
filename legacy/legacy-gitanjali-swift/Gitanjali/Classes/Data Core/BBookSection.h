//
//  BBookSection.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDefines.h"
#import "BParagraph.h"
#import <libxml/xmlmemory.h>
#import <libxml/parser.h>

@class BBookBody;

@interface BBookSection : NSObject 
{
	BParagraph*				_title;
	BParagraph*				_contentTitle;
	
	//Array of BParagraph or BBokSection
	NSMutableArray*			_content;
	
	BBookBody*				_bookBody;

}

@property(readonly) BParagraph*		title;
@property(readonly) BParagraph*		contentTitle;
@property(readonly) NSArray*		content;
@property(readonly)	BBookBody*		bookBody;

+ (id)deserialize:(xmlNodePtr)node withBookBody:(BBookBody*)bookBody;

@end
