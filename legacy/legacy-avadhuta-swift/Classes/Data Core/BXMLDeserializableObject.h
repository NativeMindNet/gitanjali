//
//  BXMLDeserializableObject.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/xmlmemory.h>
#import <libxml/parser.h>

@protocol BXMLDeserializableObject

@required

+ (id)deserialize:(xmlNodePtr)node;

@end
