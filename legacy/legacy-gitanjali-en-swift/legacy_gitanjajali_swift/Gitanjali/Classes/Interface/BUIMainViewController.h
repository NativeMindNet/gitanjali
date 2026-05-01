//
//  BUIMainViewController.h
//  books
//
//  Created by Dmitry Panin on 25.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "BBook.h"
#import "BUIPageView.h"
#import "BUIControl.h"

extern NSString*	BUIChangeBookPageNotification;
extern NSString*	BUIChangeBookPageKey;
extern NSString*	BUIChangeBookPageAnimatedKey;
extern NSString*	BUIHighlightedWordKey;

@interface BUIMainViewController : UIViewController
{
	BBook*							_book;
	int								_currentPageIndex;
	BUIPageView*					_pageView;
	BUIPageView*					_newPageView;
	UILabel*						_pageNumber;
	
	UIView*							_contentView;
	UISwipeGestureRecognizer*		_leftSwipeRecognizer;
	UISwipeGestureRecognizer*		_rightSwipeRecognizer;
	
	UIBarButtonItem*				_searchButton;
	UIBarButtonItem*				_backButton;
	NSArray*						_bookmarks;
	
	BOOL							_searchResultsMode;
	NSString*						_searchString;
	NSArray*						_searchResultPages;
	UIViewAnimationTransition		_animationTransition;
	
	UIView*							_mainView;
	NSMutableArray*					_controls;
	NSMutableArray*					_pageControls;
	
	UINavigationController*			_searchNavigationController;
}

@property(readonly)	BOOL	searchResultsMode;
@property(readonly) BBook*	book;

- (id)initWithBook:(BBook*)book;
- (id)initWithBook:(BBook*)book searchString:(NSString*)searchString resultPages:(NSArray*)pages selectedIndex:(int)index;

@end
