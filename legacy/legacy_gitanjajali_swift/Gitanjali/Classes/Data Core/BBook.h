//
//  BBook.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDefines.h"
#import "BBookHeader.h"
#import "BBookBody.h"
#import "BXMLDeserializableObject.h"

@interface BBook : NSObject<BXMLDeserializableObject>
{
	BBookHeader*	_header;
	BBookBody*		_body;
}

@property(readonly)	BBookHeader*	header;
@property(readonly)	BBookBody*		body;

@end
