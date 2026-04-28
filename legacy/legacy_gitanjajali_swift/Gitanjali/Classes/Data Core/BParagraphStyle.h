//
//  BParagraphStyle.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXMLDeserializableObject.h"
#import "BDefines.h"

@interface BParagraphStyle : NSObject <BXMLDeserializableObject> 
{
	NSString*			_fontName;
	float				_fontSize;
	UITextAlignment		_textAlignment;
	UIColor*			_textColor;
	UIColor*			_backgroundColor;
}

@property(copy)		NSString*			fontName;
@property(assign)	float				fontSize;
@property(assign)	UITextAlignment		textAlignment;
@property(retain)	UIColor*			textColor;
@property(retain)	UIColor*			backgroundColor;

- (id)initDefaultTextStyle;
- (id)initDefaultHeaderStyle;

+ (id)deserialize:(xmlNodePtr)node;

- (BOOL)loadAdditionalItemsFromNode:(xmlNodePtr)node;

@end
