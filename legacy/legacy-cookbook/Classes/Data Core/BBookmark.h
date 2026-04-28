//
//  BBookmark.h
//  books
//
//  Created by Dmitry Panin on 01.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBookPage;

@interface BBookmark : NSObject
{
	BBookPage*	_pageRef;
}

@property(retain) BBookPage*	page;

@end
