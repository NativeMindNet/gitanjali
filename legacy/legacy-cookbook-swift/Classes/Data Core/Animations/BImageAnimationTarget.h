//
//  BImageAnimationTarget.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BAnimationTarget.h"

@interface BImageAnimationTarget : BAnimationTarget <BXMLDeserializableObject>
{
    NSString*		_imagePath;
	UIImageView*	_imageView;
}

- (void)createView;
- (void)disposeView;

@end
