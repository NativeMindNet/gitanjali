//
//  BParagraphStylesStorage.h
//  books
//
//  Created by Dmitry Panin on 24.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BParagraphStyle.h"
#import "BDefines.h"

@interface BParagraphStylesStorage : NSObject 
{
	NSMutableDictionary*	_storage;
	int						_counter;
}

- (BParagraphStyle*)styleForName:(NSString*)name;
- (void)setStyle:(BParagraphStyle*)style forName:(NSString*)name;

- (NSString*)generateNameForUnnamedStyle;
- (NSString*)nameOfTheDefaultStyle;
- (NSString*)nameOfTheDefaultHeaderStyle;

@end
