//
//  BUIPageView.h
//  books
//
//  Created by Dmitry Panin on 25.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBookPage.h"
#import "BUIAnimationView.h"

@class BUIPageView;

@protocol BUIPageViewDelegate
- (void)pageViewDidFinishPageLoading:(BUIPageView*)sender;
@end


@interface BUIPageView : UIView 
{
	UIImageView*					_backgroundView;
	BUIAnimationView*				_animationView;
	
	UIWebView*						_webEngine;
	BBookPage*						_page;
	NSString*						_highlightString;
	UILabel*						_pageNumber;
	NSObject<BUIPageViewDelegate>*	_delegate;
	
	BOOL							_loadingContnent;
}

@property(readonly)	BBookPage*						page;
@property(readonly)	NSString*						highlightedString;
@property(assign)	NSObject<BUIPageViewDelegate>*	delegate;
@property(readonly)	BOOL							loadingContent;

- (id)initWithFrame:(CGRect)frame page:(BBookPage*)page highlightString:(NSString*)str;
- (void)playAnimation;
- (void)stopAnimation;

- (void)relayout;

@end
