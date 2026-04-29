//
//  BUITitlesSearchViewController.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUITitlesSearchViewController.h"
#import "BUIMainViewController.h"
#import "BUIFormattedCell.h"

#define CAPTION_KEY		@"caption"
#define PAGE_REF_KEY	@"page_ref"
#define PAGE_NUM_KEY	@"page_num"
#define SECTION_REF_KEY	@"section_ref"
#define DEPTH_KEY		@"depth"

NSInteger alphabetSortingComparator(id obj1, id  obj2, void * context)
{
	NSString* str1 = [[obj1 objectForKey: CAPTION_KEY] text];
	NSString* str2 = [[obj2 objectForKey: CAPTION_KEY] text];
	
	return [str1 compare:str2 options: NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
};

static void fillContentsTree(BBookSection* section, NSMutableArray* arr, int depth);

@interface BUITitlesSearchViewController(Private)<UITableViewDelegate, UITableViewDataSource>
- (void)_updateViews;
@end 

@implementation BUITitlesSearchViewController

- (void)dealloc
{	
	[self prepareForRelease];
	[_tableView release];
	[_nothingFoundLabel release];
	
	[_allContents release];
	[_filteredContents release];
	[_book release];
	
	[super dealloc];
}

- (void)prepareForRelease
{
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
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
		
		_allContents = [[NSMutableArray alloc] init];
		
		fillContentsTree(_book.body.rootSection, _allContents, 0);
		[_allContents sortUsingFunction: alphabetSortingComparator context: nil];
	}
	
	return self;
}

- (void)searchWithString:(NSString*)string
{
	[_filteredContents removeAllObjects];
	
	if(!string.length)
	{
		[_filteredContents addObjectsFromArray: _allContents];
		[self _updateViews];
		return;
	}
	
	for(NSDictionary* dict in _allContents)
	{
		NSString* caption = [[dict objectForKey: CAPTION_KEY] text];
		
		if([caption rangeOfString:string options: NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound)
		{
			[_filteredContents addObject: dict];
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
	
	_filteredContents = [[NSMutableArray alloc] initWithArray: _allContents];
	
	_tableView = [[UITableView alloc] initWithFrame: self.view.bounds 
											  style: UITableViewStylePlain];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return _filteredContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BUIFormattedCell* cell = (BUIFormattedCell*)[_tableView dequeueReusableCellWithIdentifier: @"content_cell"];
	
	if(!cell)
	{
		cell = [[[BUIFormattedCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"content_cell"] autorelease];
	}
	
	cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [[[_filteredContents objectAtIndex: [indexPath row]] objectForKey: PAGE_NUM_KEY] intValue]];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.paragraph = [[_filteredContents objectAtIndex: [indexPath row]] objectForKey: CAPTION_KEY];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//[_tableView deselectRowAtIndexPath:indexPath animated: YES];
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	
	BBookPage* page = [[_filteredContents objectAtIndex: [indexPath row]] objectForKey: PAGE_REF_KEY];
	
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: page, BUIChangeBookPageKey, [NSNumber numberWithBool: YES], BUIChangeBookPageAnimatedKey, nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: BUIChangeBookPageNotification
														object: nil 
													  userInfo: params];
}

- (void)_updateViews
{
	if(_filteredContents.count)
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

void fillContentsTree(BBookSection* section, NSMutableArray* arr, int depth)
{
	for(BBookSection* subSection in section.content)
	{
		if(![subSection isKindOfClass: [BBookSection class]])
		{
			continue;
		}
		
		
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: 0];
		[dict setObject:subSection forKey: SECTION_REF_KEY];
		[dict setObject:[NSNumber numberWithInt: depth] forKey: DEPTH_KEY];
		
		if(subSection.title.text)
		{
			[dict setObject:subSection.contentTitle forKey: CAPTION_KEY];
		}
		
		//searching for the fisrt paragraph to get page
		BBookPage* page = nil;
		
		if(subSection.title.page)
		{
			page = subSection.title.page;
		}
		else
		{
			for(BParagraph* paragraph in subSection.content)
			{
				if(![paragraph isKindOfClass: [BParagraph class]])
				{
					continue;
				}
				
				if(paragraph.page)
				{
					page = paragraph.page;
				}
			}
		}
		
		if(page)
		{	
			[dict setObject: [NSNumber numberWithInt: page.number] forKey: PAGE_NUM_KEY];
			[dict setObject: page forKey: PAGE_REF_KEY];
		}
		
		[arr addObject: dict];
		
		fillContentsTree(subSection, arr, depth + 1);
	}
}

