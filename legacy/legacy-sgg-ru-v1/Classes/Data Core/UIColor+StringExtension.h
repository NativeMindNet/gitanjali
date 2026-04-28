//
//  UIColor+StringExtension.h
//  books
//
//  Created by Dmitry Panin on 24.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor(StringExtension)
+ (UIColor*)colorWithString:(NSString*)string;
- (NSString*)htmlString;
@end

