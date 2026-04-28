//
//  BUIBookmarksViewController.m
//  books
//
//  Created by Dmitry Panin on 02.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIBookmarksViewController.h"
#import "BBookmarkManager.h"

@interface BUIBookmarksViewController(Private)<UITableViewDelegate, UITableViewDataSource>
- (void)_onEditButton;
- (void)_onBackButton;
- (void)_updateEditButton;
@end


@implementation BUIBookmarksViewController

@synthesize book = _book;
@synthesize delegate = _delegate;

- (void)dealloc
{
	self.delegate = nil;
	
	[_tableView release];
	[_editButton release];
	[_headerToolbar release];
	[_captionLabel release];
	[_book release];
	
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
		_bookmarks = [[[BBookmarkManager sharedManager] bookmarksForBook: _book] mutableCopy];
	}
	
	return self;
}

- (void)viewDidLoad
{
	self.title = @"Bookmarks";
	
	NSMutableArray* barItems = [NSMutableArray arrayWithCapacity: 0];
	
	UIBarButtonItem* backItem = [[[UIBarButtonItem alloc] initWithTitle: @"Back" 
																  style: UIBarButtonItemStyleDone 
																 target: self 
																 action: @selector(_onBackButton)] autorelease];
	backItem.width = 50.0f;
	[barItems addObject: backItem];
	
	[barItems addObject: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease]];
	
	_captionLabel = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 180.0f, 38.0f)];
	_captionLabel.textAlignment = UITextAlignmentCenter;
	_captionLabel.backgroundColor = [UIColor clearColor];
	_captionLabel.textColor = [UIColor darkGrayColor];
	_captionLabel.shadowOffset = CGSizeMake(0.0f, -2.0f);
	_captionLabel.shadowColor = [UIColor whiteColor];
	_captionLabel.font = [UIFont boldSystemFontOfSize: 20.0f];
	_captionLabel.text = @"Bookmarks";
	
	UIBarButtonItem* headerItem = [[[UIBarButtonItem alloc] initWithCustomView: _captionLabel] autorelease];
	[barItems addObject: headerItem];
	
	[barItems addObject: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease]];
	
	_editButton = [[UIBarButtonItem alloc] initWithTitle: @"Edit" 
												style: UIBarButtonItemStyleBordered 
												target: self 
												action: @selector(_onEditButton)];
				   
	_editButton.width = 50.0f;
	[barItems addObject: _editButton];
	
	_headerToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0.0f,
																  0.0f, 
																  self.view.bounds.size.width,
																  44.0f)];
	[_headerToolbar setItems: barItems];
	_headerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview: _headerToolbar];
	
	CGRect plainTable = CGRectMake(0.0f, 
								   44.0f, 
								   self.view.bounds.size.width,
								   self.view.bounds.size.height - 44.0f);
	
	_tableView = [[UITableView alloc] initWithFrame: plainTable 
											  style: UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	[self.view addSubview: _tableView];
	
	[self _updateEditButton];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return _bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier: @"bookmark_cell"];
	
	if(!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"bookmark_cell"] autorelease];
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	
	BBookPage* page = [[_bookmarks objectAtIndex: [indexPath row]] page];
	
	cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [page number]];
	
	NSString* sectionName = @"No Name";
	
	for(int i = 0; i < page.sections.count; i++)
	{
		sectionName = [(BBookSection*)[[page sections] objectAtIndex: i] contentTitle].text;
		
		if(sectionName.length)
		{
			break;
		}
	}
	
//	cell.textLabel.text = page.comments.text.length ? page.comments.text : @"No Index";
	cell.textLabel.text = sectionName;
	cell.textLabel.font = [UIFont fontWithName:@"MurariChandUni" size: 20];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_tableView deselectRowAtIndexPath:indexPath animated: YES];
	
	int index = [_book.body.pages indexOfObject: [[_bookmarks objectAtIndex: [indexPath row]] page]];
	
	if(index == NSNotFound)
	{
		return;
	}
	
	if([_delegate respondsToSelector: @selector(bookmarksViewController:pageWithIndexDidPicked:)])
	{
		[_delegate bookmarksViewController: self pageWithIndexDidPicked: index];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_bookmarks removeObjectAtIndex: [indexPath row]];
	[[BBookmarkManager sharedManager] setBookmarks:_bookmarks forBook: _book];
	
	if(!_bookmarks.count)
	{
		[_tableView setEditing:NO animated: YES];
	}
	
	[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationLeft];
	
	[self _updateEditButton];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	
	[_bookmarks exchangeObjectAtIndex:[fromIndexPath row] withObjectAtIndex:[toIndexPath row]];
	[[BBookmarkManager sharedManager] setBookmarks:_bookmarks forBook: _book];
}

- (void)_onBackButton
{
	if([_delegate respondsToSelector: @selector(bookmarksViewControllerDidCancelled:)])
	{
		[_delegate bookmarksViewControllerDidCancelled: self];
	}
}
				   
- (void)_onEditButton
{
	[_tableView setEditing: !_tableView.editing animated: YES];
	[self _updateEditButton];
}

- (void)_updateEditButton
{
	if(_tableView.editing && _bookmarks.count)
	{
		_editButton.style = UIBarButtonItemStyleDone;
		_editButton.title = @"Done";
	}
	else
	{
		_editButton.style = UIBarButtonItemStyleBordered;
		_editButton.title = @"Edit";
	}
	
	if(!_bookmarks.count)
	{
		_editButton.enabled = NO;
	}
	else
	{
		_editButton.enabled = YES;	
	}

	
}

@end
