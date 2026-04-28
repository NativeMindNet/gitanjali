//
//  booksAppDelegate.h
//  books
//
//  Created by Dmitry Panin on 20.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface booksAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow*					window;
	UINavigationController*		mainNavigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

