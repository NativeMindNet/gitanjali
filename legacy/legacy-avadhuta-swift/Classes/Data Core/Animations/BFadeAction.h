//
//  BFadeAction.h
//  books
//
//  Created by Dmitry Panin on 04.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBasicAction.h"

@interface BFadeAction : BBasicAction<BXMLDeserializableObject>
{
	float	_startAlpha;
	float	_endAlpha;
}

@property(assign) float startAlpha;
@property(assign) float endAlpha;

@end
