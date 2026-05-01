//
//  BUIBookmarksViewController.h
//  books
//
//  Created by Dmitry Panin on 02.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBook.h"

@class BUIBookmarksViewController;

@protocol BUIBookmarksViewControllerDelegate
@optional
- (void)bookmarksViewController:(BUIBookmarksViewController*)sender pageWithIndexDidPicked:(int)index;
- (void)bookmarksViewControllerDidCancelled:(BUIBookmarksViewController*)sender;
@end

@interface BUIBookmarksViewController : UIViewController
{
	BBook*											_book;
	NSObject<BUIBookmarksViewControllerDelegate>* _delegate;
	
	UITableView*									_tableView;
	
	UIToolbar*										_headerToolbar;
	UILabel*										_captionLabel;
	UIBarButtonItem*								_editButton;
	
	NSMutableArray*									_bookmarks;
}

@property(readonly)	BBook* book;
@property(assign)	NSObject<BUIBookmarksViewControllerDelegate>* delegate;

- (id)initWithBook:(BBook*)book;

@end
