//
//  BUICommentsSearchViewController.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUICommentsSearchViewController.h"
#import "BUIMainViewController.h"
#import "BUIFormattedCell.h"

@interface BUICommentsSearchViewController(Private)<UITableViewDelegate, UITableViewDataSource>
- (void)_updateViews;
@end

@implementation BUICommentsSearchViewController

@synthesize parentNavController = _parentNavController;

- (void)dealloc
{
	[self  prepareForRelease];
	[_allComments release];
	[_filteredComments release];
	[_tableView release];
	[_nothingFoundLabel release];
	[_book release];
	[super dealloc];
}

- (id)initWithBook:(BBook*)book
{
	if((self = [super init]))
	{
		_book = [book retain];
		
		_allComments = [[NSMutableArray alloc] init];
		
		for(BBookPage* page in _book.body.pages)
		{
			if(page.comments.text.length)
			{
				[_allComments addObject: page];
			}
		}
		
		NSArray* res =[_allComments sortedArrayWithOptions:0 usingComparator: ^ NSComparisonResult(id page1, id page2)
					   {
						   NSString* comments1 = ((BBookPage*)page1).comments.text;
						   NSString* comments2 = ((BBookPage*)page2).comments.text;
						   return [comments1 compare:comments2 options: NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
					   }];
		
		[_allComments removeAllObjects];
		[_allComments addObjectsFromArray: res];
	}
	return self;
}

- (void)prepareForRelease
{
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
}

- (void)searchWithString:(NSString*)string
{
	[_filteredComments removeAllObjects];
	
	if(!string.length)
	{
		[_filteredComments addObjectsFromArray: _allComments];
		[self _updateViews];
		return;
	}

	
	for(BBookPage* page in _allComments)
	{
		if([page.comments.text rangeOfString:string options: NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound)
		{
			[_filteredComments addObject: page];
		}
	}
	
	[self _updateViews];
}

- (void)hideSelectionAfterTimeout
{
	[self performSelector: @selector(_hideSelectionInternal) 
			   withObject: nil 
			   afterDelay: 2.0];
}

- (void)_hideSelectionInternal
{
	NSIndexPath* selection = [_tableView indexPathForSelectedRow];
	
	if(selection)
	{
		[_tableView deselectRowAtIndexPath:selection animated: YES];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_filteredComments = [[NSMutableArray alloc] initWithArray: _allComments];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style: UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.separatorColor = [UIColor lightGrayColor];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	_nothingFoundLabel = [[UILabel alloc] initWithFrame: self.view.bounds];
	_nothingFoundLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_nothingFoundLabel.textAlignment = UITextAlignmentCenter;
	_nothingFoundLabel.numberOfLines = 0;
	_nothingFoundLabel.textColor = [UIColor darkGrayColor];
	_nothingFoundLabel.text = @"Nothing is Found";
	
	[self _updateViews];
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _filteredComments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BUIFormattedCell* cell = (BUIFormattedCell*)[_tableView dequeueReusableCellWithIdentifier: @"text_search_cell"];
	
	if(!cell)
	{
		cell = [[BUIFormattedCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"text_search_cell"];
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	
	BBookPage* page = [_filteredComments objectAtIndex: [indexPath row]];
	
	cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [page number]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.paragraph = page.comments;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	
	BBookPage* page = [_filteredComments objectAtIndex: [indexPath row]];
	
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: page, BUIChangeBookPageKey, [NSNumber numberWithBool: YES], BUIChangeBookPageAnimatedKey, nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: BUIChangeBookPageNotification
														object: nil 
													  userInfo: params];
//removed by request
//	
//	BBookPage* page = [_filteredComments objectAtIndex: [indexPath row]];
//	
//	NSArray* sortedArray = [_filteredComments sortedArrayWithOptions:0 usingComparator: ^ NSComparisonResult(id page1, id page2)
//							{
//								BBookPage* p1 = (BBookPage*)page1;
//								BBookPage* p2 = (BBookPage*)page2;
//								
//								if(p1.number > p2.number)
//								{
//									return NSOrderedDescending;
//								}
//								
//								if(p1.number < p2.number)
//								{
//									return NSOrderedAscending;
//									
//								}
//								
//								return NSOrderedSame;
//							}];
//	
//	BUIMainViewController* controller = [[BUIMainViewController alloc] initWithBook: _book 
//																	   searchString: nil
//																		resultPages: sortedArray
//																	  selectedIndex: [sortedArray indexOfObject: page]];
//	[_parentNavController pushViewController:controller animated: YES];
//	[controller release];
}

- (void)_updateViews
{
	if(_filteredComments.count)
	{
		[_nothingFoundLabel removeFromSuperview];
		
		_tableView.frame = self.view.bounds;
		[self.view addSubview: _tableView];
		[_tableView reloadData];
	}
	else
	{
		[_tableView removeFromSuperview];
		
		_nothingFoundLabel.frame = self.view.bounds;
		[self.view addSubview: _nothingFoundLabel];
	}
}

@end
