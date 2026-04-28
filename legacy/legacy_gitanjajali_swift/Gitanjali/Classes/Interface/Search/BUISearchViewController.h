//
//  BUISearchViewController.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBook.h"

@interface BUISearchViewController : UIViewController
{
	NSMutableArray*			_childControllers;
	UISegmentedControl*		_searchModeSegmentedControl;

	UIView*					_parentView;
	UIView*					_contentView;	
	UIToolbar*				_inputBar;
	
	UITextField*			_textInput;	
	BBook*					_book;
	
	int						_activeControllerIndex;
}

- (id)initWithBook:(BBook*)book;

@end
