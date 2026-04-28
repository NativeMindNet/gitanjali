//
//  BScaleAction.h
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBasicAction.h"

@interface BScaleAction : BBasicAction<BXMLDeserializableObject>
{
	float	_startScale;
	float	_endScale;
}

@property(assign) float startScale;
@property(assign) float endScale;

@end
