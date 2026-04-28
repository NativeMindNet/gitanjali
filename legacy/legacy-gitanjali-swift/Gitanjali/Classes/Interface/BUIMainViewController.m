//
//  BUIMainViewController.m
//  books
//
//  Created by Dmitry Panin on 25.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIMainViewController.h"
#import "BBookPage.h"
#import "BUISearchViewController.h"
#import "BBookmarkManager.h"
#import "BUIBookmarksViewController.h"
#import "BToolFunctions.h"
#import "BUISharedAudioPlayerView.h"
#import "BUIControl.h"

#define kSavedPageKey @"saved_page"

NSString*	BUIChangeBookPageNotification  = @"BUIChangeBookPageNotification";
NSString*	BUIChangeBookPageKey  = @"BUIChangeBookPageKey";
NSString*	BUIChangeBookPageAnimatedKey = @"BUIChangeBookPageAnimatedKey";
NSString*	BUIHighlightedWordKey = @"BUIHighlightedWordKey";

@interface BUIMainViewController(Private)<	BUIPageViewDelegate,
											BUIBookmarksViewControllerDelegate,
											BUISharedAudioPlayerViewDelegate>
- (void)_onSearchButton;
- (void)_onContentsButton;
- (void)_onBackButton;
- (void)_onPrevButton;
- (void)_onNextButton;
- (void)_onLeftSwipe;
- (void)_onRightSwipe;
- (void)_onAudioButton;
- (void)_onBookmarksView;
- (void)_onAddBookmark;
- (void)_onPlayerButton;
- (BOOL)_loadPageWithIndex:(int)num animated:(BOOL)animated transition:(UIViewAnimationTransition)transition searchString:(NSString*)string;
- (void)_finalizePageLoading;
- (void)_onCurlAnimtionDidFinished;
- (void)_updateCurrentPageBookmarksStatus;
- (void)_updateBookmarks;
- (void)_onChangePageNotification:(NSNotification*)notification;
- (void)_onReturnToNormalMode;
- (void)_onControlTapNotification:(NSNotification*)mnotification;
- (void)_onAudioStopButton;
- (void)_relayoutPlayStopControls;
@end


@implementation BUIMainViewController

@synthesize book = _book;
@synthesize searchResultsMode = _searchResultsMode;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[_controls release];
	[_pageControls release];
	[_leftSwipeRecognizer release];
	[_rightSwipeRecognizer release];
	
	[_searchButton release];
	[_backButton release];
	
	[_contentView release];
	[_pageView release];
	[_newPageView release];
	
	[_searchString release];
	[_searchResultPages release];
	
	[_book release];
	[_bookmarks release];
	
	[_mainView release];
	
	[_searchNavigationController release];
	
	[super dealloc];
}

- (id)init
{
	NSAssert(0, @"Do not use init method. Use initWithBook: insted");
	[self release];
	return nil;
}

- (id)initWithBook:(BBook *)book
{
	if((self = [super init]))
	{
		if(!book)
		{
			[self release];
			return nil;
		}
		
		_book = [book retain];
		[self _updateBookmarks];
		_searchResultsMode = NO;
	}
	
	return self;
}

- (id)initWithBook:(BBook*)book searchString:(NSString*)searchString resultPages:(NSArray*)pages selectedIndex:(int)index
{
	if([self initWithBook: book])
	{
		if(searchString)
		{
			_searchString = [[NSString alloc] initWithString: searchString];
		}
		_searchResultPages = [[NSArray alloc] initWithArray: pages];
		_searchResultsMode = YES;
		_currentPageIndex = index;
	}
	
	return self;
}

- (void)viewDidLoad
{
	if(_book.header.orientation == kBookOrientationLandscape)
	{
		CGRect frame = self.view.frame;
		frame.size.width = 1024 - frame.origin.x;
		frame.size.height = 768 - frame.origin.y;
		
		self.view.frame = frame;
	}
	
	_mainView = [[UIView alloc] initWithFrame: self.view.bounds];

	if(self.searchResultsMode)
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle: @"Normal Mode" 
																				   style: UIBarButtonItemStyleBordered 
																				  target: self
																				  action: @selector(_onReturnToNormalMode)] autorelease];
		
		
	}

	
	
	CGRect contentViewFrame = CGRectMake(0.0f,
										 0.0f, 
										 _mainView.bounds.size.width, 
										 _mainView.bounds.size.height);
	
	_contentView = [[UIView alloc] initWithFrame: contentViewFrame];
	_contentView.backgroundColor = [UIColor whiteColor];
	_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_mainView addSubview: _contentView];
	
	//adding controls
	_controls = [[NSMutableArray alloc] init];
	_pageControls = [[NSMutableArray alloc] init];
	
	for(BControlInfo* controlInfo in _book.header.controls)
	{
		BUIControl* control = [[[BUIControl alloc] initWithControlInfo: controlInfo] autorelease];
		
		if(!control)
		{
			continue;
		}
		
		[_mainView addSubview: control];
		[_controls addObject: control];
	}
	
	_leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action: @selector(_onLeftSwipe)];
	_leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[_contentView addGestureRecognizer: _leftSwipeRecognizer];
	
	_rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action: @selector(_onRightSwipe)];
	_rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[_contentView addGestureRecognizer: _rightSwipeRecognizer];
	
	int pageNum = _currentPageIndex;
	
	if(!self.searchResultsMode)
	{
		pageNum = [[NSUserDefaults standardUserDefaults] integerForKey: kSavedPageKey];
	}

	[self _loadPageWithIndex:pageNum animated:NO transition: UIViewAnimationTransitionCurlDown searchString: nil];
	
	if(!_searchResultsMode)
	{
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(_onChangePageNotification:) 
													 name:BUIChangeBookPageNotification 
												   object: nil];
	}
	
	_mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: _mainView];
	
	if(_searchResultsMode)
	{
		BOOL enableBookmarksControl = NO;
		BOOL enableSearch = NO;
		
		for(BUIControl* ctrl in _controls)
		{
			if(ctrl.type == kControlTypeBookmarks)
			{
				ctrl.enabled = enableBookmarksControl;
			}
			
			if(ctrl.type == kControlTypeSearch)
			{
				ctrl.enabled = enableSearch;
			}
		}
	}
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
	
	float height = [BUISharedAudioPlayerView shrinkedHeight];
	
	if([BUISharedAudioPlayerView sharedInstance].state == kSharedAudioPlayerViewStateExpanded)
	{
		height = [BUISharedAudioPlayerView expandedHeight];
	}
	
	//put shared player
	CGRect mainViewFrame = self.view.bounds;
	mainViewFrame.size.height -= height;
	_mainView.frame = mainViewFrame;
	
	[BUISharedAudioPlayerView sharedInstance].delegate = self;
	UIView* sharedPlayerView = [BUISharedAudioPlayerView sharedInstance];
	sharedPlayerView.alpha = 1.0;
	sharedPlayerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	CGRect playerFrame;
	playerFrame.size = CGSizeMake(self.view.bounds.size.width, height);
	playerFrame.origin.x = 0.0f;
	playerFrame.origin.y = self.view.bounds.size.height - playerFrame.size.height;
	sharedPlayerView.frame = playerFrame;
	[self.view addSubview: sharedPlayerView];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(_onControlTapNotification:) 
												 name:BUIControlDidPressedNotification
											   object: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver: self 
													name: BUIControlDidPressedNotification
												  object: nil];
	
	[super viewDidDisappear: animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if(_book.header.orientation == kBookOrientationPortrait)
	{
		return  UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
	}
	else
	{
		return  UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	}
		
	return NO;
}

- (void)bookmarksViewController:(BUIBookmarksViewController*)sender pageWithIndexDidPicked:(int)index
{
	[self _updateBookmarks];
	[self _loadPageWithIndex: index animated:NO transition: UIViewAnimationTransitionCurlDown searchString: nil];
	[self.navigationController dismissModalViewControllerAnimated: YES];
}

- (void)bookmarksViewControllerDidCancelled:(BUIBookmarksViewController*)sender
{
	[self _updateBookmarks];
	[self _updateCurrentPageBookmarksStatus];
	[self.navigationController dismissModalViewControllerAnimated: YES];
}

- (void)_onSearchButton
{	
	if(!_searchNavigationController)
	{
		BUISearchViewController* controller = [[BUISearchViewController alloc] initWithBook: _book];
		_searchNavigationController = [[UINavigationController alloc] initWithRootViewController: controller];
		_searchNavigationController.navigationBarHidden = YES;
		[controller release];	
	}

	[self.navigationController presentModalViewController:_searchNavigationController animated: YES];
}

- (void)sharedAudioPlayer:(BUISharedAudioPlayerView*)sender stateDidChanged:(BUISharedAudioPlayerViewState)newState
{
	
	[UIView beginAnimations:nil context: nil];
	[UIView setAnimationDuration: 0.5];
	
	if(newState == kSharedAudioPlayerViewStateExpanded)
	{
		//fix of the issue with player animation
		//CGRect mainViewFrame = self.view.bounds;
		//mainViewFrame.size.height -= [BUISharedAudioPlayerView expandedHeight];
		//_mainView.frame = mainViewFrame;
		
		UIView* sharedPlayerView = [BUISharedAudioPlayerView sharedInstance];
		sharedPlayerView.alpha = 1.0;
		sharedPlayerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		CGRect playerFrame;
		playerFrame.size = CGSizeMake(self.view.bounds.size.width, [BUISharedAudioPlayerView expandedHeight]);
		playerFrame.origin.x = 0.0f;
		playerFrame.origin.y = self.view.bounds.size.height - playerFrame.size.height;
		sharedPlayerView.frame = playerFrame;
		[self.view addSubview: sharedPlayerView];
	}
	else
	{
		//fix of the issue with player animation
		//CGRect mainViewFrame = self.view.bounds;
		//mainViewFrame.size.height -= [BUISharedAudioPlayerView shrinkedHeight];
		//_mainView.frame = mainViewFrame;
		
		UIView* sharedPlayerView = [BUISharedAudioPlayerView sharedInstance];
		sharedPlayerView.alpha = 1.0;
		sharedPlayerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		CGRect playerFrame;
		playerFrame.size = CGSizeMake(self.view.bounds.size.width, [BUISharedAudioPlayerView shrinkedHeight]);
		playerFrame.origin.x = 0.0f;
		playerFrame.origin.y = self.view.bounds.size.height - playerFrame.size.height;
		sharedPlayerView.frame = playerFrame;
		[self.view addSubview: sharedPlayerView];
	}
	
	[UIView commitAnimations];
	
	if(newState == kSharedAudioPlayerViewStateShrinked)
	{
		[_pageView relayout];
	}
}

- (void)sharedAudioPlayerPlaybackStateDidChanged:(BUISharedAudioPlayerView *)sender
{
	[self _relayoutPlayStopControls];
}

- (void)_onBackButton
{
	if(!_searchResultsMode)
	{
		[[BUISharedAudioPlayerView sharedInstance] stop];
	}
	[self.navigationController.parentViewController dismissModalViewControllerAnimated: YES];
}

- (void)_onPrevButton
{	
	[self _loadPageWithIndex:_currentPageIndex - 1 animated:YES transition: UIViewAnimationTransitionCurlDown searchString: nil];
}

- (void)_onNextButton
{	
	[self _loadPageWithIndex:_currentPageIndex + 1 animated:YES transition: UIViewAnimationTransitionCurlUp  searchString: nil];
}

- (void)_onPlayerButton
{
	if([BUISharedAudioPlayerView sharedInstance].state == kSharedAudioPlayerViewStateShrinked)
	{
		[BUISharedAudioPlayerView sharedInstance].state = kSharedAudioPlayerViewStateExpanded;
	}
	else
	{
		[BUISharedAudioPlayerView sharedInstance].state = kSharedAudioPlayerViewStateShrinked;
	}
}

- (void)_onLeftSwipe
{
	[self _loadPageWithIndex:_currentPageIndex + 1 animated:YES transition: UIViewAnimationTransitionCurlUp searchString: nil];
}

- (void)_onRightSwipe
{
	[self _loadPageWithIndex:_currentPageIndex - 1 animated:YES transition: UIViewAnimationTransitionCurlDown searchString: nil];
}

- (void)_onAudioButton
{
	NSString* name = extractNameFromSoundFile(_pageView.page.soundURL);
	
	[[BUISharedAudioPlayerView sharedInstance] loadFileWithURL:_pageView.page.soundURL name: name looping: _pageView.page.loopSound];
	[[BUISharedAudioPlayerView sharedInstance] play];
	[self _relayoutPlayStopControls];
}

- (void)_onAudioStopButton
{
	[[BUISharedAudioPlayerView sharedInstance] stop];
	[self _relayoutPlayStopControls];
}

- (void)_relayoutPlayStopControls
{
	if([[_pageView.page soundURL] absoluteString])
	{
		BOOL showStop = NO;
		
		if([BUISharedAudioPlayerView sharedInstance].playing && [_pageView.page soundURL])
		{
			NSString* audioPath = [[_pageView.page soundURL] absoluteString];
			NSString* playingPath = [[BUISharedAudioPlayerView sharedInstance].audioURL absoluteString];
			
			if(audioPath && playingPath && [audioPath isEqualToString: playingPath])
			{
				showStop = YES;
			}
		}

		
		for(BUIControl* ctrl in _controls)
		{
			if(ctrl.type == kControlTypeStopSound)
			{
				ctrl.enabled = showStop;
			}
			
			if(ctrl.type == kControlTypePlaySound)
			{
				ctrl.enabled = !showStop;
			}
		}
	}
	else
	{
		for(BUIControl* ctrl in _controls)
		{
			if(ctrl.type == kControlTypeStopSound)
			{
				ctrl.enabled = NO;
			}
			
			if(ctrl.type == kControlTypePlaySound)
			{
				ctrl.enabled = NO;
			}
		}
	}
}

- (void)_onBookmarksView
{ 
	[self _updateBookmarks];
	BUIBookmarksViewController* controller = [[BUIBookmarksViewController alloc] initWithBook: _book];
	controller.modalPresentationStyle = UIModalPresentationFormSheet;
	controller.delegate = self;
	[self.navigationController presentModalViewController: controller animated: YES];
	[controller release];
}

- (void)_onAddBookmark
{
	NSArray* pagesSource = _book.body.pages;
	
	if(self.searchResultsMode)
	{
		pagesSource = _searchResultPages;
	}
	
	BBookPage* page = [pagesSource objectAtIndex: _currentPageIndex];
		
	BBookmark* bookmark = [[[BBookmark alloc] init] autorelease];
	bookmark.page = page;
	
	[[BBookmarkManager sharedManager] addBookmark:bookmark  forBook: _book];
	
	[self _updateBookmarks];
	[self _updateCurrentPageBookmarksStatus];
}

- (void)_updateBookmarks
{
	[_bookmarks release];
	_bookmarks = [[[BBookmarkManager sharedManager] bookmarksForBook: _book] retain];
}

- (BOOL)_pagePresentInBookmarks:(BBookPage*)page
{
	for(BBookmark* bookmark in _bookmarks)
	{
		if(bookmark.page == page)
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)_updateCurrentPageBookmarksStatus
{
	NSArray* pagesSource = _book.body.pages;
	
	if(self.searchResultsMode)
	{
		pagesSource = _searchResultPages;
	}

	BBookPage* page = [pagesSource objectAtIndex: _currentPageIndex];
	
	BOOL enableAddBookmarksControls = YES;
	
	if(![self _pagePresentInBookmarks: page])
	{
		enableAddBookmarksControls = YES;
	}
	else
	{
		enableAddBookmarksControls = NO;
	}
	
	for(BUIControl* ctrl in _controls)
	{
		if(ctrl.type == kControlTypeAddBookmark)
		{
			ctrl.enabled = enableAddBookmarksControls;
		}
	}
}

- (BOOL)_loadPageWithIndex:(int)num animated:(BOOL)animated transition:(UIViewAnimationTransition)transition searchString:(NSString*)string
{
	NSArray* pagesSource = _book.body.pages;
	
	if(self.searchResultsMode)
	{
		pagesSource = _searchResultPages;
	}
	
	if(num >= pagesSource.count)
	{
		return NO;
	}
	
	BBookPage* page = [pagesSource objectAtIndex: num];
	_currentPageIndex = num;
	
	_newPageView = [[BUIPageView alloc] initWithFrame: _contentView.bounds page: page highlightString: string];
	_newPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	BOOL enableAddBookmarksControls = YES;
	
	if(![self _pagePresentInBookmarks: page])
	{
		enableAddBookmarksControls = YES;
	}
	else
	{
		enableAddBookmarksControls = NO;
	}
	
	for(BUIControl* ctrl in _controls)
	{
		if(ctrl.type == kControlTypeAddBookmark)
		{
			ctrl.enabled = enableAddBookmarksControls;
		}
	}
	
	if(animated && _newPageView.loadingContent)
	{
		_newPageView.delegate = self;
		_animationTransition = transition;
		self.view.userInteractionEnabled = NO;
		return YES;
	}

	if(animated)
	{
		_animationTransition = transition;
	}
	else 
	{
		_animationTransition = UIViewAnimationTransitionNone;
	}

	
	[self _finalizePageLoading];
	
	return YES;
}

- (void)pageViewDidFinishPageLoading:(BUIPageView*)sender
{
	[self _finalizePageLoading];
	_newPageView.delegate = nil;
}

- (void)_finalizePageLoading
{
	self.view.userInteractionEnabled = YES;
	
	[_pageView removeFromSuperview];
	[_pageView release];
	
	NSArray* pagesSource = _book.body.pages;
	
	if(self.searchResultsMode)
	{
		pagesSource = _searchResultPages;
	}
	
	int num = _currentPageIndex;
	BBookPage* page = [pagesSource objectAtIndex: num];
	
	_pageView = _newPageView;
	_newPageView = nil;
	
	[_pageControls makeObjectsPerformSelector: @selector(removeFromSuperview)];
	[_pageControls removeAllObjects];
	
	//adding page controls
	for(BControlInfo* controlInfo in page.pageControls)
	{
		BUIControl* control = [[[BUIControl alloc] initWithControlInfo: controlInfo] autorelease];
		
		if(!control)
		{
			continue;
		}
		
		[_mainView addSubview: control];
		[_pageControls addObject : control];
	}
	
	if(_animationTransition != UIViewAnimationTransitionNone)
	{
		[UIView beginAnimations:nil context: nil];
		[UIView setAnimationDuration: 0.4f];
		[UIView setAnimationTransition: _animationTransition forView: _mainView cache: NO];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(_onCurlAnimtionDidFinished)];
	}
	
	[_contentView addSubview: _pageView];
	
	if(_animationTransition != UIViewAnimationTransitionNone)
	{
		[UIView commitAnimations];
	}
	
 	self.title = [NSString stringWithFormat: @"Page %d from %d", _currentPageIndex + 1, pagesSource.count];
	
	
	BOOL enablePrevButton = YES;
	
	if(num)
	{
		enablePrevButton = YES;
	}
	else
	{
		enablePrevButton = NO;
	}
	
	for(BUIControl* ctrl in _controls)
	{
		if(ctrl.type == kControlTypePrevPage)
		{
			ctrl.enabled = enablePrevButton;
		}
	}

	BOOL enableNextButton = YES;
	
	if(num < pagesSource.count - 1)
	{
		enableNextButton = YES;
	}
	else
	{
		enableNextButton = NO;
	}
	
	for(BUIControl* ctrl in _controls)
	{
		if(ctrl.type == kControlTypeNextPage)
		{
			ctrl.enabled = enableNextButton;
		}
	}
	
	if(!self.searchResultsMode)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:num forKey: kSavedPageKey];
	}
	
	BOOL enableSoundButton = YES;
	
	if(page.soundURL)
	{
		enableSoundButton = YES;
	}
	else
	{
		enableSoundButton = NO;
	}
	
	for(BUIControl* ctrl in _controls)
	{
		if(ctrl.type == kControlTypePlaySound)
		{
			ctrl.enabled = enableSoundButton;
		}
		
		if(ctrl.type == kControlTypeStopSound)
		{
			ctrl.enabled = enableSoundButton;
		}
	}
	
	if(page.autoplaySound && page.soundURL)
	{
		NSString* name = extractNameFromSoundFile(_pageView.page.soundURL);
	
		[[BUISharedAudioPlayerView sharedInstance] loadFileWithURL: page.soundURL name: name looping: _pageView.page.loopSound];
		[[BUISharedAudioPlayerView sharedInstance] play];
	}
	
	[self _relayoutPlayStopControls];
}

- (void)_onCurlAnimtionDidFinished
{
	[_pageView playAnimation];
}

- (void)_onChangePageNotification:(NSNotification*)notification
{
	int index = [_book.body.pages indexOfObject: [notification.userInfo objectForKey: BUIChangeBookPageKey]];
	
	if(index == NSNotFound)
	{
		return;
	}
	
	BOOL animated = [[notification.userInfo objectForKey: BUIChangeBookPageAnimatedKey] boolValue];
	NSString* highlightedString = [notification.userInfo objectForKey: BUIHighlightedWordKey];
	
	[self _loadPageWithIndex:index animated: NO transition: UIViewAnimationTransitionCurlDown  searchString: highlightedString];
	[self.navigationController dismissModalViewControllerAnimated: animated];
}

- (void)_onReturnToNormalMode
{
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [_searchResultPages objectAtIndex: _currentPageIndex], BUIChangeBookPageKey,
																		[NSNumber numberWithBool: NO], BUIChangeBookPageAnimatedKey, nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: BUIChangeBookPageNotification
														object: nil 
													  userInfo: params];
}

- (void)_onControlTapNotification:(NSNotification*)notification
{
	NSNumber* controlType = [notification.userInfo objectForKey: BUIControlTypeKey];
	BControlInfo* info = [notification.userInfo objectForKey: BUIControlInfoKey];
	
	if(!controlType)
	{
		return;
	}

	switch ([controlType intValue]) 
	{
		case kControlTypePrevPage:
			[self _onPrevButton];
			break;
			
		case kControlTypeNextPage:
			[self _onNextButton];
			break;
			
		case kControlTypeBookmarks:
			[self _onBookmarksView];
			break;
			
		case kControlTypeAddBookmark:
			[self _onAddBookmark];
			break;
			
			
		case kControlTypePlaySound:
			[self _onAudioButton];
			break;
			
		case kControlTypeStopSound:
			[self _onAudioStopButton];
			break;
			
		case kControlTypeTogglePlayer:
			[self _onPlayerButton];
			break;
			
		case kControlTypeSearch:
			[self _onSearchButton];
			break;
			
		case kControlTypePageLink:
		{
			NSString* str = info.argument;
			int pageIndex = [str intValue];
			
			[self _loadPageWithIndex: pageIndex 
							animated: YES 
						  transition: pageIndex < _currentPageIndex ? UIViewAnimationTransitionCurlDown : UIViewAnimationTransitionCurlUp
						searchString: nil];
		}
			break;
			
		default:
			break;
	}
}

@end
