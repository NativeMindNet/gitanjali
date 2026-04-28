//
//  BAnimationTarget.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXMLDeserializableObject.h"

@interface BAnimationTarget : NSObject <BXMLDeserializableObject>
{
    UIView*	_view;
}

@property(readonly)	UIView*	view;

- (void)createView;
- (void)disposeView;
- (void)reset;

- (void)update:(float)delta;

@end
