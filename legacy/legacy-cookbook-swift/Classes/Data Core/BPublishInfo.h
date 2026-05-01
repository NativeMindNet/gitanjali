//
//  BPublishInfo.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXMLDeserializableObject.h"
#import "BDefines.h"

@interface BPublishInfo : NSObject<BXMLDeserializableObject>
{
	NSString*		_publisher;
	NSString*		_city;
	NSString*		_year;
}

@property(copy) NSString*	publisher;
@property(copy) NSString*	city;
@property(copy) NSString*	year;

@end
