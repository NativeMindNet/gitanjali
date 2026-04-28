//
//  booksAppDelegate.m
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "booksAppDelegate.h"
#import "BUIMainViewController.h"
#import "BToolFunctions.h"

@implementation booksAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{   
	xmlDocPtr docPtr = xmlReadFile([[[NSBundle mainBundle] pathForResource:@"example" ofType: @"xml"] UTF8String], NULL, 0);
	BBook* book = [BBook deserialize: xmlDocGetRootElement(docPtr)];
	xmlFreeDoc(docPtr);
	
	BUIMainViewController* controller = [[BUIMainViewController alloc] initWithBook: book];
	
	mainNavigationController = [[UINavigationController alloc] initWithRootViewController: controller];
	mainNavigationController.navigationBarHidden = YES;
	[controller release];
	
	[window addSubview: mainNavigationController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc 
{
	[mainNavigationController release];
	[window release];
    [super dealloc];
}


@end
