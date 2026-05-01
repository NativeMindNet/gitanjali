//
//  BUISearchViewController.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUISearchViewController.h"
#import "BUITextSearchViewController.h"
#import "BUICommentsSearchViewController.h"
#import "BUITitlesSearchViewController.h"

@interface BUISearchViewController(Private)<UITextFieldDelegate>
- (void)_onBackButton;
- (void)_onKeyboardWillAppearNotification:(NSNotification*)notification;
- (void)_onKeyboardWillDisappearNotification:(NSNotification*)notification;
- (void)_processSearchWithString:(NSString*)string;
- (void)_setActivePage:(int)page;
- (void)_onSegmentedControllDidSwitched;
- (void)_showKeyboard;
@end

@implementation BUISearchViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	for(NSObject<BUISearchResultViewer>* obj in _childControllers)
	{
		[obj prepareForRelease];
	}
	
	[_childControllers release];
	[_inputBar release];
	[_textInput release];
	[_contentView release];
	[_parentView release];
	[_searchModeSegmentedControl release];
	[_book release];
	[super dealloc];
}

- (id)initWithBook:(BBook*)book
{
	if((self = [super init]))
	{
		_book = [book retain];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.title = @"Search";
	
	NSArray* itemNames = [NSArray arrayWithObjects: @"Content", @"Index", @"Titles", nil];
	_searchModeSegmentedControl = [[UISegmentedControl alloc] initWithItems: itemNames];
	_searchModeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	_searchModeSegmentedControl.selectedSegmentIndex = 1;
	[_searchModeSegmentedControl addTarget: self
									action: @selector(_onSegmentedControllDidSwitched) 
						  forControlEvents: UIControlEventValueChanged];
	
	UIBarButtonItem* switchItems = [[[UIBarButtonItem alloc] initWithCustomView: _searchModeSegmentedControl] autorelease];
	UIBarButtonItem* backButtonItem = [[[UIBarButtonItem alloc] initWithTitle: @"Back" 
																			style: UIBarButtonItemStyleDone
																		   target: self
																		   action: @selector(_onBackButton)] autorelease];
	
	_parentView = [[UIView alloc] initWithFrame: self.view.bounds];
	_parentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: _parentView];
	
	_contentView = [[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, _parentView.bounds.size.width, _parentView.bounds.size.height - 44.0f)];
	_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_parentView addSubview: _contentView];
	
	_inputBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0.0f, _parentView.bounds.size.height - 44.0f, _parentView.bounds.size.width, 44.0f)];
	_inputBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[_parentView addSubview: _inputBar];
	
	float inputWidth = 500;
	
	if(_book.header.orientation == kBookOrientationLandscape)
	{
		inputWidth = 750;
	}
	
	_textInput = [[UITextField alloc] initWithFrame: CGRectMake(0.0f, 0.0f, inputWidth, 30.0f)];
	_textInput.borderStyle = UITextBorderStyleRoundedRect;
	_textInput.delegate = self;
	_textInput.returnKeyType = UIReturnKeySearch;
	_textInput.clearButtonMode = UITextFieldViewModeAlways;
	
	UIBarButtonItem* flexibleItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace 
																				   target: nil action: nil] autorelease];
	
	UIBarButtonItem* searchItem = [[[UIBarButtonItem alloc] initWithCustomView: _textInput] autorelease];
	
	[_inputBar setItems: [NSArray arrayWithObjects:backButtonItem, flexibleItem, switchItems, flexibleItem, searchItem, nil]];
	
	_childControllers = [[NSMutableArray alloc] initWithCapacity: 3];
	
	{
		BUITextSearchViewController* controller = [[BUITextSearchViewController alloc] initWithBook: _book];
		controller.parentNavController = self.navigationController;
		[_childControllers addObject: controller];
		[controller release];
	}
	
	{
		BUICommentsSearchViewController* controller = [[BUICommentsSearchViewController alloc] initWithBook: _book];
		controller.parentNavController = self.navigationController;
		[_childControllers addObject: controller];
		[controller release];
	}
	
	{
		BUITitlesSearchViewController* controller = [[BUITitlesSearchViewController alloc] initWithBook: _book];
		[_childControllers addObject: controller];
		[controller release];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(_onKeyboardWillAppearNotification:) 
												 name: UIKeyboardWillShowNotification 
											   object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(_onKeyboardWillDisappearNotification:) 
												 name: UIKeyboardWillHideNotification
											   object: nil];
	
	[self _setActivePage: 1];
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

- (void)_showKeyboard
{
	[_textInput becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
	
	for(UIViewController<BUISearchResultViewer>* ctrl in _childControllers)
	{
		[ctrl hideSelectionAfterTimeout];
	}

	//[self performSelector:@selector(_showKeyboard) withObject:nil afterDelay: 0.1];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	[super viewWillDisappear: animated];
	[_inputBar resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString* str = [textField.text stringByReplacingCharactersInRange:range withString: string];
	[self _processSearchWithString: str];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	[self _processSearchWithString: @""];
	return YES;
}

- (void)_onBackButton
{
	[self.navigationController dismissModalViewControllerAnimated: YES];
	
}

- (void)_onKeyboardWillAppearNotification:(NSNotification*)notification
{
	CGRect keyboardFrame;
	NSDictionary* userInfo = notification.userInfo;
	float keyboardSlideDuration = [[userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
	keyboardFrame = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	
	UIInterfaceOrientation theStatusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	float keyboardShiftAmount = 0.0f;
	
	if UIInterfaceOrientationIsLandscape(theStatusBarOrientation)
	{
		keyboardShiftAmount = keyboardFrame.size.width;
	}
	else 
	{
		keyboardShiftAmount = keyboardFrame.size.height;
	}
	
	[UIView beginAnimations: @"ShiftUp" context: nil];
	[UIView setAnimationDuration: keyboardSlideDuration];
	_parentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,  self.view.bounds.size.height - keyboardShiftAmount);
	[UIView commitAnimations];
}

- (void)_onKeyboardWillDisappearNotification:(NSNotification*)notification
{
	NSDictionary* userInfo = notification.userInfo;
	float keyboardSlideDuration = [[userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	[UIView beginAnimations: @"ShiftDown" context: nil];
	[UIView setAnimationDuration: keyboardSlideDuration];
	_parentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,  self.view.bounds.size.height);
	[UIView commitAnimations];
}

- (void)_processSearchWithString:(NSString*)string
{
	UIViewController<BUISearchResultViewer>* newController = [_childControllers objectAtIndex: _activeControllerIndex];
	[newController searchWithString: string];
}

- (void)_setActivePage:(int)page
{
	UIViewController<BUISearchResultViewer>* oldController = [_childControllers objectAtIndex: _activeControllerIndex];
	[oldController searchWithString: @""];
	[oldController.view removeFromSuperview];
	
	_activeControllerIndex = page;

	UIViewController<BUISearchResultViewer>* newController = [_childControllers objectAtIndex: _activeControllerIndex];
	newController.view.frame = _contentView.bounds;
	newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_contentView addSubview: newController.view];
	[newController searchWithString: _textInput.text];
}

- (void)_onSegmentedControllDidSwitched
{
	[self _setActivePage: _searchModeSegmentedControl.selectedSegmentIndex];
}

@end
