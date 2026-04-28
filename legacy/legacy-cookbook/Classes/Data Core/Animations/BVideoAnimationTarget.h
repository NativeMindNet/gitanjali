//
//  BVideoAnimationTarget.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BAnimationTarget.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface BVideoAnimationTarget : BAnimationTarget <BXMLDeserializableObject>
{
	NSString*					_videoPath;
	BOOL						_repeat;
	
	MPMoviePlayerController*	_moviePlayerController;
	BOOL						_shouldStartPlayback;
	BOOL						_playbackWasInterruptedByBackground;
}

- (void)createView;
- (void)disposeView;
- (void)reset;

- (void)update:(float)delta;

@end
