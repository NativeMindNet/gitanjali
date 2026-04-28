//
//  BUITitlesSearchViewController.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUISearchResultViewer.h"
#import "BBook.h"

@interface BUITitlesSearchViewController : UIViewController<BUISearchResultViewer> 
{
	BBook*										_book;
	
	UITableView*								_tableView;
	UILabel*									_nothingFoundLabel;
	
	NSMutableArray*								_allContents;
	NSMutableArray*								_filteredContents;
}

- (void)searchWithString:(NSString*)string;
- (void)prepareForRelease;

@end
