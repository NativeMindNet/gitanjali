//
//  BUIAnimationView.h
//  books
//
//  Created by Dmitry Panin on 19.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BUIAnimationView : UIView 
{
    NSMutableArray*		_animations;
	NSDate*				_lastUpdateDate;
	NSTimer*			_updateTimer;
}

- (id)initWithFrame:(CGRect)frame animations:(NSArray*)animations;
- (void)playAnimation;
- (void)stopAnimation;
- (void)resetTimer;

@end
