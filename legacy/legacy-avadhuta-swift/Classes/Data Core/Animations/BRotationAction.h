//
//  BRotationAction.h
//  books
//
//  Created by Dmitry Panin on 03.03.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBasicAction.h"

@interface BRotationAction : BBasicAction<BXMLDeserializableObject>
{
	float _startAngle;
	float _finishAngle;
}

@property(assign) float startAngle;
@property(assign) float finishAngle;

@end
