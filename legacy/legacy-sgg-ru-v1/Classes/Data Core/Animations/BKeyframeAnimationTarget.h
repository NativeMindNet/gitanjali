//
//  BKeyframeAnimationTarget.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BAnimationTarget.h"

@interface BKeyframeAnimationTarget : BAnimationTarget <BXMLDeserializableObject>
{
    NSString*			_imagesFolder;
	NSMutableArray*		_images;
	
	float				_imagesPerSecond;
	int					_repeatCount;
	
	float				_currentProgress;
	int					_currentRepeatsCount;
	
	UIImageView*		_imageView;
}

- (void)createView;
- (void)disposeView;
- (void)reset;

- (void)update:(float)delta;

@end
