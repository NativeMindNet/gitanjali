//
//  BUITextSearchViewController.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUITextSearchViewController.h"
#import "BUIMainViewController.h"
#import "BUIFormattedCell.h"

#define PAGE_KEY	@"page"
#define CAPTION_KEY	@"caption"
#define DEPTH_KEY	@"depth"

@interface BUITextSearchViewController(Private)<UITableViewDelegate, UITableViewDataSource>
- (void)_threadMain;
- (void)_searchDidFinished:(NSArray*)result;
- (void)_showResults;
@end

static void fillContentsTree(BBookSection* section, NSMutableArray* arr, int depth);

@implementation BUITextSearchViewController

@synthesize  parentNavController = _parentNavController;

- (void)dealloc
{
	[self prepareForRelease];
	[_searchResults release];
	[_tableView release];
	[_book release];
	
	[super dealloc];
}

- (void)prepareForRelease
{
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	[_searchThread cancel];
	[_searchCondition broadcast];
	[_threadLock lock];
	[_threadLock unlock];
	
	[_searchThread release];
	_searchThread = nil;
	[_threadLock release];
	_threadLock = nil;
	[_searchCondition release];
	_searchCondition = nil;
	[_searchString release];
	_searchString = nil;
	
	[_contents release];
	_contents = nil;
}

- (id)initWithBook:(BBook *)book
{
	if((self = [super init]))
	{
		_book = [book retain];
		_contents = [[NSMutableArray alloc] initWithCapacity: 0];
		fillContentsTree(book.body.rootSection, _contents, 0);
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style: UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.separatorColor = [UIColor lightGrayColor];
//	_tableView.rowHeight = 36;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	_nothingFoundLabel = [[UILabel alloc] initWithFrame: self.view.bounds];
	_nothingFoundLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_nothingFoundLabel.textAlignment = UITextAlignmentCenter;
	_nothingFoundLabel.numberOfLines = 0;
	_nothingFoundLabel.textColor = [UIColor darkGrayColor];
	
	_loadingIndiator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	_loadingIndiator.frame = self.view.bounds;
	_loadingIndiator.contentMode = UIViewContentModeCenter;
	_loadingIndiator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	
	_threadLock = [[NSLock alloc] init];
	_searchCondition = [[NSCondition alloc] init];
	_searchThread = [[NSThread alloc] initWithTarget: self 
											selector: @selector(_threadMain) 
											  object: nil];
	[_searchThread start];
	
	[self _showResults];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
	return 40.1;
	
}




- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _searchResults.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	BUIFormattedCell* cell = (BUIFormattedCell*)[_tableView dequeueReusableCellWithIdentifier: @"text_search_cell"];

	if(!cell)
	{
		cell = [[BUIFormattedCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"text_search_cell"];
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	
	NSDictionary* dict = [_searchResults objectAtIndex: [indexPath row]];
	
	BBookPage* page = [dict objectForKey: PAGE_KEY];
	BParagraph* caption = [dict objectForKey: CAPTION_KEY];

	
	
	//azazello	
	cell.detailTextLabel.baselineAdjustment  = UIBaselineAdjustmentAlignCenters;
	cell.textLabel.baselineAdjustment  = UIBaselineAdjustmentAlignCenters;
	//
	cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [page number]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.indentationWidth = 30.0f;
	cell.indentationLevel = [[dict objectForKey: DEPTH_KEY] intValue];
	cell.paragraph = caption;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	
	NSDictionary* dict = [_searchResults objectAtIndex: [indexPath row]];
	BBookPage* page = [dict objectForKey: PAGE_KEY];
	
	NSDictionary* params = nil;
	
	if(_searchString)
	{
		params = [NSDictionary dictionaryWithObjectsAndKeys: page, BUIChangeBookPageKey, 
							[NSNumber numberWithBool: YES],	BUIChangeBookPageAnimatedKey, 
							_searchString, BUIHighlightedWordKey, nil];
	}
	else
	{
		params = [NSDictionary dictionaryWithObjectsAndKeys: page, BUIChangeBookPageKey, 
				  [NSNumber numberWithBool: YES], BUIChangeBookPageAnimatedKey, nil];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: BUIChangeBookPageNotification
														object: nil 
													  userInfo: params];
}

- (void)searchWithString:(NSString*)string
{
	[_searchString release];
	
	if(!string)
	{
		string = @"";
	}
	
	_searchString = [[NSString alloc] initWithString: string];
	_workPendingForThread = YES;
	_searchRequestWasChanged = YES;
	[_searchCondition broadcast];
	
	[_tableView removeFromSuperview];
	[_nothingFoundLabel removeFromSuperview];
	_loadingIndiator.frame = self.view.bounds;
	[self.view addSubview: _loadingIndiator];
	[_loadingIndiator startAnimating];
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

- (void)_searchDidFinished:(NSArray*)result
{
	[_searchResults release];
	_searchResults = [[NSArray alloc] initWithArray: result];
	
	[_loadingIndiator removeFromSuperview];
	[_loadingIndiator stopAnimating];
	[self _showResults];
}

- (void)_threadMain
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[_threadLock lock];
	
	while (![[NSThread currentThread] isCancelled]) 
	{
		if(!_workPendingForThread)
		{
			[_searchCondition lock];
			[_searchCondition wait];
			[_searchCondition unlock];
			continue;
		}
		
		NSAutoreleasePool* cyclePool = [[NSAutoreleasePool alloc] init];
		
		NSString* searchString = [NSString stringWithString: _searchString];
		
		_workPendingForThread = NO;
		_searchRequestWasChanged = NO;
		
		//searching
		@try 
		{
			if(!searchString.length)
			{
				[self performSelectorOnMainThread:@selector(_searchDidFinished:) withObject:_contents waitUntilDone:YES];
				@throw [NSException exceptionWithName:nil reason:nil userInfo:nil];
			}
			
			NSMutableArray* res = [NSMutableArray arrayWithCapacity: 0];
			
			for(BBookPage* page in _book.body.pages)
			{
				
				for(BParagraph* p in page.paragraphs)
				{
					if(_searchRequestWasChanged || [[NSThread currentThread] isCancelled])
					{
						@throw [NSException exceptionWithName:nil reason:nil userInfo:nil];
					}
					
					if([p.text rangeOfString:searchString options: NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound)
					{
					
						int depth = 0;
						
						BParagraph* sectionTitleParagraph = nil;
						
						for(int i = 0; i < page.sections.count; i++)
						{
							BParagraph* p = [(BBookSection*)[[page sections] objectAtIndex: i] contentTitle];
							
							if(p.text.length)
							{		
								sectionTitleParagraph = p;
								break;
							}
						}
						
						NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: 0];
						
						[dict setObject:page forKey: PAGE_KEY];
						[dict setValue: sectionTitleParagraph forKey: CAPTION_KEY];
						[dict setObject:[NSNumber numberWithInt: depth] forKey: DEPTH_KEY];
						
						[res addObject: dict];
						break;
					}
				}	
			}
	
			//search ended
			[self performSelectorOnMainThread:@selector(_searchDidFinished:) withObject:res waitUntilDone:YES];
		}
		@catch (NSException *exception) 
		{
			
		}
		
	
		[cyclePool release];
	}
	
	[_threadLock unlock];
	[pool release];
}

- (void)_showResults
{
	if(_searchResults.count)
	{
		[_nothingFoundLabel removeFromSuperview];
		
		_tableView.frame = self.view.bounds;
		[self.view addSubview:_tableView];
		[_tableView reloadData];
	}
	else
	{
		[_tableView removeFromSuperview];
		
		_nothingFoundLabel.frame = self.view.bounds;
		[self.view addSubview:_nothingFoundLabel];	
		
		if(_searchString.length)
		{
			_nothingFoundLabel.text = @"Nothing is found";
		}
		else
		{
			_nothingFoundLabel.text = @"Please input a search phrase";
		}
	}
}

@end


void fillContentsTree(BBookSection* section, NSMutableArray* arr, int depth)
{
	for(BBookSection* subSection in section.content)
	{
		if(![subSection isKindOfClass: [BBookSection class]])
		{
			continue;
		}
		
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: 0];
		
		BBookPage* page = nil;
		
		if(subSection.title.page)
		{
			page = subSection.title.page;
			[dict setObject: page forKey: PAGE_KEY];
		}
		
		if(subSection.title.text)
		{
			[dict setObject:subSection.contentTitle forKey: CAPTION_KEY];
		}
		
		[dict setObject: [NSNumber numberWithInt: depth] forKey: DEPTH_KEY];
		
		[arr addObject: dict];
	
		fillContentsTree(subSection, arr, depth + 1);
	}
}

