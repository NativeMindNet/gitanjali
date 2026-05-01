//
//  BToolFunctions.h
//  books
//
//  Created by Dmitry Panin on 26.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/xmlmemory.h>
#import <libxml/parser.h>

#ifdef __cplusplus
extern "C"
{
#endif

NSString* pathOfResourceWithTemplate(NSString *templ);
NSString* extractNameFromSoundFile(NSURL* file);

	
#ifdef __cplusplus
}
#endif