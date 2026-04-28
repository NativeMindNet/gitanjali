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
	kControlTypeToggleAnimations,
	
} BControlType;

typedef enum 
{
	kControlStateNormal,
	kControlStateHighlighted,
	kControlStateDisabled,
	
} BControlState;

@interface BControlInfo : NSObject<BXMLDeserializableObject>
{
	BControlType			_type;
	
	NSMutableDictionary*	_centersDict;
	
	UIImage*				_normalImage;
	UIImage*				_highlightedImage;
	UIImage*				_disabledImage;
	id						_argument;
	BOOL					_checkmark;
	BOOL					_dragable;
}

@property(assign)	BControlType	type;
@property(retain)	UIImage*		normalImage;
@property(retain)	UIImage*		highlightedImage;
@property(retain)	UIImage*		disabledImage;
@property(retain)	id				argument;
@property(assign)	BOOL			checkmark;
@property(assign)	BOOL			dragable;

- (CGPoint)centerForState:(BControlState)state;
- (void)setCenter:(CGPoint)center forState:(BControlState)state;

@end
