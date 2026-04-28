//
//  BUIPageView.m
//  books
//
//  Created by Dmitry Panin on 25.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIPageView.h"
#import "BDefines.h"
#import "UIColor+StringExtension.h"
#import "BParagraphStyle.h"
#import "BParagraphStylesStorage.h"
#import "BBookBody.h"

#import <UIKit/UIKit.h>

@interface BGPlainWebView : UIWebView
{
}

@end


@implementation BGPlainWebView


-(id)initWithCoder:(NSCoder*) coder
{
    if((self = [super initWithCoder:coder]))
	{

	}
	
	return self;
}  

-(void)layoutSubviews
{	
	//Hide shadow (hide every UIImageView instance).
	for(UIView *eachSubview in [[[self subviews] objectAtIndex:0] subviews])
	{
        if ([eachSubview isKindOfClass:[UIImageView class]] && eachSubview.frame.size.width >= 320.0)
		{
			eachSubview.hidden = YES;	
		}
	}
		
}

@end

@interface BUIPageView(Private)<UIWebViewDelegate>
- (NSString*)_generateHTMLStringForPage:(BBookPage*)page highlightString:(NSString*)highlights;
@end

const float hBorder = 5;
const float vBorder = 5;

@implementation BUIPageView

@synthesize page = _page;
@synthesize highlightedString = _highlightString;
@synthesize delegate = _delegate;
@synthesize loadingContent = _loadingContnent;

- (void)dealloc
{
	self.delegate = nil;

	_webEngine.delegate = nil;
	[_webEngine stopLoading];
	[_webEngine release];
	
	[_backgroundView release];
	[_pageNumber release];
	[_animationView release];
	
	[_highlightString release];
	[_page release];
	
	[super dealloc];
}

- (id)init
{
	NSAssert(0, @"Do not use init method. Use initWithFrame:page: insted");
	[self release];
	return nil;
}

- (id)initWithFrame:(CGRect)frame
{
	NSAssert(0, @"Do not use initWithFrame: method. Use initWithFrame:page: insted");
	[self release];
	return nil;
}

- (id)initWithFrame:(CGRect)frame page:(BBookPage*)page highlightString:(NSString*)str
{
	if((self = [super initWithFrame: frame]))
	{
		if(!page)
		{
			[self release];
			return nil;
		}
		_page = [page retain];	
		_highlightString  = [str retain];
		
		self.userInteractionEnabled = NO;
		self.clipsToBounds = YES;

		_backgroundView = [[UIImageView alloc] initWithFrame: self.bounds];
		_animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_backgroundView.contentMode = UIViewContentModeCenter;
		_backgroundView.backgroundColor = _page.backgroundColor;
		
		if(_page.backgroundImagePath)
		{
			_backgroundView.image = [UIImage imageWithContentsOfFile: _page.backgroundImagePath];
		}
		
		[self addSubview: _backgroundView];
		
		if(_page.animations.count)
		{
			_animationView = [[BUIAnimationView alloc] initWithFrame:self.bounds animations: _page.animations];
			_animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		
		[self addSubview: _animationView];
		
		if(_page.showNumber)
		{
			
			_pageNumber = [[UILabel alloc] initWithFrame: CGRectMake(-8.0f,
																	 self.bounds.size.height - 20,
																	 self.bounds.size.width, 
																	 -1942.0f)];
			
			_pageNumber.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
			_pageNumber.backgroundColor = [UIColor clearColor];
			_pageNumber.font = [UIFont italicSystemFontOfSize: 12];
			_pageNumber.textAlignment = UITextAlignmentRight;
			_pageNumber.text = [NSString stringWithFormat:@"%d", _page.number];
			
			[self addSubview: _pageNumber];
			
		}
		
		if(_page.paragraphs.count)
		{
			CGRect webframe = self.bounds;
			webframe.origin.x += hBorder;
			webframe.origin.y += vBorder;
			webframe.size.width -= 2.0f * hBorder;
			webframe.size.height -= 2.0f * vBorder;
			webframe.size.height -= 20.0f;
			
			_webEngine = [[BGPlainWebView alloc] initWithFrame: webframe];
			_webEngine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_webEngine.opaque = NO;
			_webEngine.backgroundColor = [UIColor clearColor];
			
			_loadingContnent = YES;
			NSString* htmlString = [self _generateHTMLStringForPage: _page highlightString: _highlightString];
	
			_webEngine.delegate = self;
			[_webEngine loadHTMLString:htmlString baseURL: nil];			
		}
	}
	
	return self;
}

- (void)relayout
{
	[self setNeedsLayout];
	_backgroundView.frame = self.bounds;
	_animationView.frame = self.bounds;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)didMoveToWindow
{
	if(self.window)
	{
		[_animationView playAnimation];
	}
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	if(!newWindow)
	{
		[_animationView stopAnimation];
	}
}

- (void)playAnimation
{
	[_animationView playAnimation];
}

- (void)stopAnimation
{
	[_animationView playAnimation];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	_loadingContnent = NO;
	
	CGRect webframe = self.bounds;
	webframe.origin.x += hBorder;
	webframe.origin.y += vBorder;
	webframe.size.width -= 2.0f * hBorder;
	webframe.size.height -= 2.0f * vBorder;
	webframe.size.height -= 20.0f;
	_webEngine.frame = webframe;
	[self addSubview: _webEngine];
	
	if([_delegate respondsToSelector: @selector(pageViewDidFinishPageLoading:)])
	{
		[_delegate pageViewDidFinishPageLoading: self];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	_loadingContnent = NO;
	
	CGRect webframe = self.bounds;
	webframe.origin.x += hBorder;
	webframe.origin.y += vBorder;
	webframe.size.width -= 2.0f * hBorder;
	webframe.size.height -= 2.0f * vBorder;
	webframe.size.height -= 20.0f;
	_webEngine.frame = webframe;
	[self addSubview: _webEngine];
	
	if([_delegate respondsToSelector: @selector(pageViewDidFinishPageLoading:)])
	{
		[_delegate pageViewDidFinishPageLoading: self];
	}
}

- (NSString*)_generateHTMLStringForPage:(BBookPage*)page highlightString:(NSString*)highlights
{
	NSMutableDictionary* usedStyles = [[NSMutableDictionary alloc] initWithCapacity: 0];
	
	for (BParagraph* p in page.paragraphs) 
	{
		BParagraphStyle* style = [page.bookBody.stylesStorage styleForName: p.styleName];
		
		if(style)
		{
			[usedStyles setObject:style forKey: p.styleName];
		}
	}
	
	NSMutableString* str = [[[NSMutableString alloc] init] autorelease];
	
	//create header
	[str appendString: @"<!doctype HTML public \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\"><html><head></head><style type=\"text/css\">"];
	
	//standard classes
	[str appendString: @"html, body {width: 100%;}\n"];
	[str appendString: @".center {width: 99%; text-align: center;} \n"];
	[str appendString: @".left {width: 99%; text-align: left;} \n"];
	[str appendString: @".right {width: 99%; text-align: right;} \n"];
	
	//putting styles on page
	for(NSString* styleName in usedStyles)
	{
		BParagraphStyle* style = [usedStyles objectForKey: styleName];
		
		NSMutableString* styleString = [[NSMutableString alloc] init];
		
		[styleString appendFormat: @"\n%@ {", styleName];
		
		if(style.textColor)
		{
			[styleString appendFormat: @"color: %@;\n", [style.textColor htmlString]];
		}
		
		if(style.backgroundColor)
		{
			[styleString appendFormat: @"background-color: %@;\n", [style.backgroundColor htmlString]];
		}
		
		NSMutableString* fontString = [[NSMutableString alloc] initWithFormat: @"font: %dpx", (int)style.fontSize];
		
		if(style.fontName)
		{
			[fontString appendFormat: @" %@", style.fontName];
		}
		
		[fontString appendString: @";\n"];
		
		[styleString appendString: fontString];
		
		[fontString release];
		
		[styleString appendString: @"}\n"];
		
		[str appendString: styleString];
		
		[styleString release];
	}
	
	if(highlights)
	{
		[str appendFormat: @"hl-text-style {background-color: %@;}\n", [BBOOK_SEARCH_RESULTS_HIGHLIGHT_COLOR htmlString]];
	}
	
	[str appendString: @"</style>"];
	[str appendString: @"<body style=\"background-color: transparent\">"];
	
	for(BParagraph* p in page.paragraphs)
	{
		if(p.hidden)
		{
			continue;
		}
		
		if(p.largeCapitalLetter)
		{
			[str appendFormat: @"<img src=\"file://%@\" style=\"float: left\"/>", p.largeCapitalLetter];
		}
		
		BParagraphStyle* style = [page.bookBody.stylesStorage styleForName: p.styleName];
		
		NSString* textAlign = @"left";
		
		if(style.textAlignment == UITextAlignmentRight)
		{
			textAlign = @"right";
		}
		
		if(style.textAlignment == UITextAlignmentCenter)
		{
			textAlign = @"center";
		}
		
		[str appendFormat: @"<div class=\"%@\"><p><%@>", textAlign, p.styleName];
		
		NSString* text = p.text;
		
		if(_highlightString)
		{
			NSRange searchRange = {0, text.length};
			NSRange foundStringRange = {NSNotFound, NSNotFound};
			
			NSString* startHighlighTag = @"<hl-text-style>";
			NSString* finshHighlighTag = @"</hl-text-style>";
			int highlighTagsLength = startHighlighTag.length + finshHighlighTag.length;
			
			while ((foundStringRange = [text rangeOfString:_highlightString options: NSCaseInsensitiveSearch range: searchRange]).location != NSNotFound) 
			{
				NSString* searchString = [text substringWithRange: foundStringRange];
				NSString* taggedString = [NSString stringWithFormat: @"%@%@%@", startHighlighTag, searchString, finshHighlighTag];
				
				text = [NSString stringWithFormat: @"%@%@%@", 
												[text substringToIndex: foundStringRange.location], 
												taggedString, 
												[text substringFromIndex: foundStringRange.location + foundStringRange.length]];
				
				searchRange.location = foundStringRange.location + foundStringRange.length + highlighTagsLength;
				searchRange.length = text.length - searchRange.location;
			}
		}
		
		[str appendFormat: @"%@", text];
		[str appendFormat: @"</%@></p></div>", p.styleName];
		
	}
	
	[str appendString: @"</body>"];
	[str appendString: @"</html>"];
	
	[usedStyles release];
	
	return str;
}


@end
