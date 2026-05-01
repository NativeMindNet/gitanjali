//
//  BImageAnimationTarget.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BImageAnimationTarget.h"
#import "BToolFunctions.h"

@implementation BImageAnimationTarget

- (void)createView
{
	if(_imageView)
	{
		return;
	}
	
	UIImage* img = [UIImage imageWithContentsOfFile: _imagePath];
	_imageView = [[UIImageView alloc] initWithImage: img];
	_imageView.contentMode = UIViewContentModeScaleToFill;
	_imageView.backgroundColor = [UIColor clearColor];
	_view = _imageView;
}

- (void)disposeView
{
	[_imageView removeFromSuperview];
	[_imageView release];
	_imageView = nil;
	_view = nil;
}

+ (id)deserialize:(xmlNodePtr)node
{
	BImageAnimationTarget* target = [[[BImageAnimationTarget alloc] init] autorelease];
	
	if(node->children && node->children->content)
	{
		target->_imagePath = [pathOfResourceWithTemplate([NSString stringWithUTF8String: (const char*)node->children->content]) retain];
	}
	else
	{
		return nil;
	}	
	
	return target;
}

@end
