//
//  BVideoAnimationTarget.m
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BVideoAnimationTarget.h"
#import "BToolFunctions.h"

@implementation BVideoAnimationTarget

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[_moviePlayerController stop];
	[_moviePlayerController release];
	[_videoPath release];
	[super dealloc];
}

- (id)init
{
	if((self = [super init]))
	{
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(_onApplicationDidBecomeActive)
													 name: UIApplicationDidBecomeActiveNotification 
												   object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(_onApplicationDidResignActivity)
													 name: UIApplicationWillResignActiveNotification 
												   object: nil];
	}
	
	return self;
}

- (void)createView
{
	if(_moviePlayerController)
	{
		return;
	}
	
	if(_videoPath && [[NSFileManager defaultManager] isReadableFileAtPath: _videoPath])
	{
		NSURL* url = [NSURL fileURLWithPath: _videoPath];
		
		_moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL: url];
		
		if(_moviePlayerController)
		{
			_moviePlayerController.shouldAutoplay = NO;
			_moviePlayerController.scalingMode = MPMovieScalingModeFill;
			_moviePlayerController.useApplicationAudioSession = YES;
			_moviePlayerController.controlStyle = MPMovieControlStyleNone;
			
			if(_repeat)
			{
				_moviePlayerController.repeatMode = MPMovieRepeatModeOne;
			}
			
			_moviePlayerController.view.frame = CGRectMake(0.0f, 0.0f,  _moviePlayerController.naturalSize.width,  _moviePlayerController.naturalSize.height);
				
			_moviePlayerController.view.backgroundColor = [UIColor clearColor];
			
			_view = _moviePlayerController.view;
			
			_shouldStartPlayback = YES;
		}
	}
}

- (void)disposeView
{
	[_moviePlayerController stop];
	[_moviePlayerController.view removeFromSuperview];
	
	_view = nil;
	
	[_moviePlayerController release];
	_moviePlayerController = nil;
}

- (void)reset
{
	[super reset];
	[_moviePlayerController stop];
	_shouldStartPlayback = YES;
}

- (void)update:(float)delta
{
	if(_shouldStartPlayback)
	{
		[_moviePlayerController play];
		_shouldStartPlayback = NO;
	}
}

+ (id)deserialize:(xmlNodePtr)node
{
	BVideoAnimationTarget* instance = [[[BVideoAnimationTarget alloc] init] autorelease];
	
	if(node->children && node->children->content)
	{
		instance->_videoPath = [pathOfResourceWithTemplate([NSString stringWithUTF8String: (const char*)node->children->content]) retain];
	}
	else
	{
		return nil;
	}	
	
	xmlChar* repeatProp = xmlGetProp(node, (xmlChar*)"repeat");
	
	if(repeatProp)
	{
		NSString* str = [NSString stringWithUTF8String: (const char*)repeatProp];
		
		if([str caseInsensitiveCompare: @"true"] == NSOrderedSame ||
		   [str caseInsensitiveCompare: @"1"] == NSOrderedSame)
		{
			instance->_repeat = YES;
		}
	}
	
	return instance;
}

- (void)_onApplicationDidResignActivity
{
	if(_moviePlayerController && _moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
	{
		[_moviePlayerController pause];
		_playbackWasInterruptedByBackground = YES;
	}
	
	
}

- (void)_onApplicationDidBecomeActive
{
	if(_playbackWasInterruptedByBackground)
	{
		[_moviePlayerController play];
		_playbackWasInterruptedByBackground = NO;
	}
}


@end
