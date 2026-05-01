//
//  BBookHeader.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXMLDeserializableObject.h"
#import "BPublishInfo.h"
#import "BPerson.h"
#import "BDefines.h"
#import "BControlInfo.h"

@interface BBookHeader : NSObject <BXMLDeserializableObject>
{
	NSString*			_identifier;
	NSMutableArray*		_authors;
	NSMutableArray*		_translators;
	NSString*			_title;
	NSString*			_language;
	NSString*			_sourceLanguage;
	NSString*			_isbn;
	NSString*			_genre;
	BPublishInfo*		_publisherInfo;
	BBookOrientation	_orientation;
	NSMutableArray*		_controls;
}

@property(copy)		NSString*			identifier;

//array of the BPerson
@property(readonly) NSMutableArray*		authors;
//array of the BPerson
@property(readonly) NSMutableArray*		translators;
@property(copy)		NSString*			title;
@property(copy)		NSString*			language;
@property(copy)		NSString*			sourceLanguage;
@property(copy)		NSString*			isbn;
@property(copy)		NSString*			genre;
@property(retain)	BPublishInfo*		publisherInfo;

@property(assign)	BBookOrientation	orientation;
@property(readonly)	NSMutableArray*		controls;


@end
