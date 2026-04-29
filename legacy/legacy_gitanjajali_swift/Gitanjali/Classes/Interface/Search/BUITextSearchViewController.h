//
//  BUITextSearchViewController.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUISearchResultViewer.h"
#import "BBook.h"

@interface BUITextSearchViewController : UIViewController<BUISearchResultViewer>
{	
	BBook*						_book;
	UITableView*				_tableView;
	UIActivityIndicatorView*	_loadingIndiator;
	UILabel*					_nothingFoundLabel;
	
	NSMutableArray*				_searchResults;
	NSMutableArray*				_contents;

	NSLock*						_threadLock;
	NSThread*					_searchThread;
	NSCondition*				_searchCondition;
	
	NSString*					_searchString;
	BOOL						_workPendingForThread;
	BOOL						_searchRequestWasChanged;
	
	UINavigationController*		_parentNavController;
	
}

@property(assign)	UINavigationController*	parentNavController;

- (id)initWithBook:(BBook*)book;

@end
