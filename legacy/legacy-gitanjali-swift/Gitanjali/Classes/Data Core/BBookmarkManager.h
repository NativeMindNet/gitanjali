//
//  BBookmarkManager.h
//  books
//
//  Created by Dmitry Panin on 01.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBookmark.h"
#import "BBook.h"

@interface BBookmarkManager : NSObject 
{

}

+ (BBookmarkManager*)sharedManager;

- (NSArray*)bookmarksForBook:(BBook*)book;
- (BOOL)addBookmark:(BBookmark*)bookmark forBook:(BBook*)book;
- (BOOL)setBookmarks:(NSArray*)bookmarks forBook:(BBook*)book;

@end
