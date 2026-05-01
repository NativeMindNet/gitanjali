//
//  BPerson.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXMLDeserializableObject.h"
#import "BDefines.h"

@interface BPerson : NSObject<BXMLDeserializableObject>
{
	NSString*	_firstName;
	NSString*	_middleName;
	NSString*	_lastName;
	NSString*	_nickname;
	NSString*	_email;
}

@property(copy) NSString*	firstName;
@property(copy) NSString*	middleName;
@property(copy) NSString*	lastName;
@property(copy) NSString*	nickname;
@property(copy) NSString*	email;

@end
