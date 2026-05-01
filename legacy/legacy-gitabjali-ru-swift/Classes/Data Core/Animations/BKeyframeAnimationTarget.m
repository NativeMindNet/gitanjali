//
//  BKeyframeAnimationTarget.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BKeyframeAnimationTarget.h"
#import "BToolFunctions.h"

@implementation BKeyframeAnimationTarget

- (void)dealloc
{
	[_imagesFolder release];
	[_images release];
	[_imageView release];
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		_imagesPerSecond = 10;
		_repeatCount = 0;
	}
	return self;
}

- (void)createView
{
	if(_images)
	{
		return;
	}
	
	[self reset];
	
	_images = [[NSMutableArray alloc] initWithCapacity: 0];
	
	NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: _imagesFolder error: nil];
	
	for(NSString* filename in contents)
	{
		NSString* ext = [filename pathExtension];
		
		if(![ext isEqualToString: @"png"] && ![ext isEqualToString: @"jpg"] && ![ext isEqualToString: @"jpeg"])
		{
			continue;
		}
		
		NSString* fullPath = [_imagesFolder stringByAppendingPathComponent: filename];
		
		UIImage* img = [UIImage imageWithContentsOfFile: fullPath];
		
		if(img)
		{
			[_images addObject: img];
		}
	}
	
	_imageView = [[UIImageView alloc] initWithFrame: CGRectZero];
	_imageView.contentMode = UIViewContentModeScaleToFill;
	_imageView.backgroundColor = [UIColor clearColor];
	
	if(_images.count)
	{
		UIImage* firstImage = [_images objectAtIndex: 0];
		_imageView.image = firstImage;
		_imageView.bounds = CGRectMake(0.0f, 0.0f, firstImage.size.width, firstImage.size.height);
	}
	
	_view = _imageView;
}

- (void)disposeView
{
	[_images release];
	_images = nil;
	
	[_imageView removeFromSuperview];
	[_imageView release];
	_imageView = nil;
	_view = nil;
}

- (void)reset
{
	[super reset];
	
	_currentProgress = 0.0f;
	_currentRepeatsCount = 0;
	
	if(_images.count)
	{
		_imageView.image = [_images objectAtIndex: 0];
	}
}

- (void)update:(float)delta
{
	if(_repeatCount && _currentRepeatsCount >= _repeatCount)
	{
		return;
	}
	
	if(!_images.count)
	{
		return;
	}
	
	_currentProgress += delta * _imagesPerSecond / _images.count;
	
	if(_currentProgress >= 1.0f)
	{
		_currentProgress = fmodf(_currentProgress, 1.0f);
		_currentRepeatsCount++;
		
		if(_repeatCount && _currentRepeatsCount >= _repeatCount)
		{
			_imageView.image = [_images lastObject];
			return;
		}
	}
	
	int index = _currentProgress * _images.count;
	
	if(index >= _images.count)
	{
		index = _images.count - 1;
	}
	
	_imageView.image = [_images objectAtIndex: index];
}

+ (id)deserialize:(xmlNodePtr)node
{
	BKeyframeAnimationTarget* instance = [[[BKeyframeAnimationTarget alloc] init] autorelease];
	
	if(node->children && node->children->content)
	{
		instance->_imagesFolder = [pathOfResourceWithTemplate([NSString stringWithUTF8String: (const char*)node->children->content]) retain];
	}
	else
	{
		return nil;
	}
	
	xmlChar* imagesPerSecProp = xmlGetProp(node, (xmlChar*)"images-per-second");
	
	if(imagesPerSecProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)imagesPerSecProp];
		instance->_imagesPerSecond = [str floatValue];
	}
	
	xmlChar* repeatsProp = xmlGetProp(node, (xmlChar*)"repeat-count");
	
	if(repeatsProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)repeatsProp];
		instance->_repeatCount = [str intValue];
	}
	
	return instance;
}


@end
