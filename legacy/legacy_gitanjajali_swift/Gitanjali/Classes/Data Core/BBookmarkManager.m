//
//  BBookmarkManager.m
//  books
//
//  Created by Dmitry Panin on 01.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BBookmarkManager.h"

@interface BBookmarkManager(Private)

- (NSString*)_bookmarksDirectory;
- (NSString*)_bookmarksFileForBook:(BBook*)book;

@end


@implementation BBookmarkManager

- (void)dealloc
{
	[super dealloc];
} 

- (id)init
{
	if(self = [super init])
	{
		BOOL dir = NO;
		
		if(![[NSFileManager defaultManager] fileExistsAtPath:[self _bookmarksDirectory] isDirectory: &dir] || !dir)
		{
			[[NSFileManager defaultManager] createDirectoryAtPath: [self _bookmarksDirectory]  withIntermediateDirectories:YES attributes: nil error: nil];
		}
	}
	return self;
}

+ (BBookmarkManager*)sharedManager
{
	static BBookmarkManager* manager = nil;
	
	if(!manager)
	{
		manager = [[BBookmarkManager alloc] init];
	}
	
	return manager;
}

- (NSArray*)bookmarksForBook:(BBook*)book
{
	NSMutableArray* res = [NSMutableArray arrayWithCapacity: 0];
	
	NSString* filePath = [self _bookmarksFileForBook: book];
	
	if(![[NSFileManager defaultManager] isReadableFileAtPath: filePath])
	{
		return res;
	}
	
	xmlDocPtr docPtr = xmlReadFile([filePath UTF8String], NULL, 0);
	
	xmlNodePtr rootNode = xmlDocGetRootElement(docPtr);
	
	if(!rootNode)
	{
		xmlFreeDoc(docPtr);
		return res;
	}
	
	xmlNodePtr dataNode = rootNode->children;
	
	while (dataNode)
	{
		if(!xmlStrcmp(dataNode->name, (xmlChar*)"b") && dataNode->children && dataNode->children->content)
		{
			int pageIndex = [[NSString stringWithUTF8String: (const char*)dataNode->children->content] intValue];
			
			if(pageIndex < book.body.pages.count && pageIndex >= 0)
			{
				BBookmark* bookmark = [[BBookmark alloc] init];
				
				bookmark.page = [book.body.pages objectAtIndex: pageIndex];
				[res addObject: bookmark];
				
				[bookmark release];
			}
		}
		
		dataNode  = dataNode->next;
	}
	
	xmlFreeDoc(docPtr);
	
	return res;
}

- (BOOL)addBookmark:(BBookmark*)bookmark forBook:(BBook*)book
{
	NSArray* currentBookmarks = [self bookmarksForBook: book];
	
	NSMutableArray* res = [NSMutableArray arrayWithArray: currentBookmarks];
	[res addObject: bookmark];
	
	[self setBookmarks:res forBook:book];
	
	return YES;
}

- (BOOL)setBookmarks:(NSArray*)bookmarks forBook:(BBook*)book
{
	
	NSString* fileName = [self _bookmarksFileForBook: book];
	
	xmlDocPtr doc = xmlNewDoc((xmlChar*)"1.0");
	
	xmlNodePtr rootNode = xmlNewNode(NULL, (xmlChar*)"bookmarks");
	
	for(BBookmark* b in bookmarks)
	{
		xmlNewChild(rootNode, NULL, (xmlChar*)"b", (xmlChar*)[[NSString stringWithFormat: @"%d", [b.page.bookBody.pages indexOfObject: b.page]] UTF8String]);
	}
	
	xmlDocSetRootElement(doc, rootNode);
	xmlSaveFile([fileName UTF8String], doc);
	
	xmlFreeDoc(doc);
	
	return YES;
}

- (NSString*)_bookmarksDirectory
{
	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																		NSUserDomainMask, YES) objectAtIndex:0];
	
	return [documentsDirectory stringByAppendingPathComponent: @"bookmarks"];
}

- (NSString*)_bookmarksFileForBook:(BBook*)book
{
	NSString* filename = [NSString stringWithFormat: @"%.4x.xml", [book.header.identifier hash]];
	return [[self _bookmarksDirectory] stringByAppendingPathComponent: filename];
}

@end
