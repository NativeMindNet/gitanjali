//
//  BControlInfo.h
//  books
//
//  Created by Dmitriy Panin on 10.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//
#import "BXMLDeserializableObject.h"

typedef enum 
{
	kControlTypePrevPage,
	kControlTypeNextPage,
	kControlTypeBookmarks,
	kControlTypeAddBookmark,
	kControlTypePlaySound,
	kControlTypeStopSound,
	kControlTypeTogglePlayer,
	kControlTypeSearch,
	kControlTypePageLink,
	
} BControlType;

@interface BControlInfo : NSObject<BXMLDeserializableObject>
{
	BControlType	_type;
	CGPoint			_center;
	UIImage*		_normalImage;
	UIImage*		_highlightedImage;
	UIImage*		_disabledImage;
	NSString*		_argument;
}

@property(assign)	BControlType	type;
@property(assign)	CGPoint			center;
@property(retain)	UIImage*		normalImage;
@property(retain)	UIImage*		highlightedImage;
@property(retain)	UIImage*		disabledImage;
@property(copy)		NSString*		argument;

@end
