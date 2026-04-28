//
//  BUICommentsSearchViewController.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUISearchResultViewer.h"
#import "BBook.h"

@interface BUICommentsSearchViewController : UIViewController<BUISearchResultViewer>
{
    BBook*						_book;
	NSMutableArray*				_allComments;
	NSMutableArray*				_filteredComments;
	
	UITableView*				_tableView;
	UILabel*					_nothingFoundLabel;
	
	UINavigationController*		_parentNavController;
}

@property(assign)	UINavigationController*		parentNavController;

- (id)initWithBook:(BBook*)book;
- (void)searchWithString:(NSString*)string;
- (void)prepareForRelease;

@end
