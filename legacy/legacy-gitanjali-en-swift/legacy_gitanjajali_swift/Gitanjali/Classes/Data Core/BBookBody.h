//
//  BBookBody.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDefines.h"
#import "BBookPage.h"
#import "BBookSection.h"
#import "BParagraphStyle.h"
#import "BParagraphStylesStorage.h"
#import "BXMLDeserializableObject.h"

@interface BBookBody : NSObject<BXMLDeserializableObject>
{
	NSMutableArray*				_pages;
	BBookSection*				_rootSection;
	BParagraphStylesStorage*	_stylesStorage;
}

@property(readonly)	NSArray*					pages;
@property(readonly)	BBookSection*				rootSection;
@property(readonly) BParagraphStylesStorage*	stylesStorage;

- (void)createEmptyPage;

//array of BPage
- (NSArray*)searchForPhrase:(NSString*)phrase;

@end
