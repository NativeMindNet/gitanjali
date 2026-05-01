//
//  UIColor+StringExtension.m
//  books
//
//  Created by Dmitry Panin on 24.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "UIColor+StringExtension.h"

@implementation UIColor(StringExtension)

+ (UIColor*)colorWithString:(NSString*)string
{
	UIColor* res = [UIColor clearColor];
	
	if(string.length != 7)
	{
		return res;
	}
	
	if([string characterAtIndex: 0] != '#')
	{
		return res;
	}
	
	NSString* rgb[3] = {nil, nil, nil};
	
	rgb[0] = [string substringWithRange: (NSRange){1, 2}];
	rgb[1] = [string substringWithRange: (NSRange){3, 2}];
	rgb[2] = [string substringWithRange: (NSRange){5, 2}];
	
	if(!rgb[0] || !rgb[1] || !rgb[2])
	{
		return res;
	}
	
	int rgbf[3] = {0, 0, 0};
	
	sscanf([rgb[0] UTF8String], "%x", &rgbf[0]);
	sscanf([rgb[1] UTF8String], "%x", &rgbf[1]);
	sscanf([rgb[2] UTF8String], "%x", &rgbf[2]);
	
	res = [UIColor colorWithRed: (float)rgbf[0] / 255.0f 
						  green: (float)rgbf[1] / 255.0f  
						   blue: (float)rgbf[2] / 255.0f 
						  alpha:1.0f];
	
	return res;
}

- (NSString*)htmlString
{
	CGColorRef colorRef = [self CGColor];
	const CGFloat* compsFloat =  CGColorGetComponents(colorRef);
	int componentsCount =  CGColorGetNumberOfComponents (colorRef);
	
	int red = 0;
	int green = 0;
	int blue = 0;
	
	if(componentsCount <=2)
	{
		red = compsFloat[0] * 255.0f;
		green = compsFloat[0] * 255.0f;
		blue = compsFloat[0] * 255.0f;
	}
	
	if(componentsCount >= 3)
	{
		red = compsFloat[0] * 255.0f;
		green = compsFloat[1] * 255.0f;
		blue = compsFloat[2] * 255.0f;
	}
	
	return [NSString stringWithFormat: @"#%.2x%.2x%.2x", red, green, blue];
}

@end
