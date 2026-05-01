//
//  BUISearchResultViewer.h
//  books
//
//  Created by Dmitry Panin on 20.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BUISearchResultViewer
@required
- (void)searchWithString:(NSString*)string;
- (void)prepareForRelease;
- (void)hideSelectionAfterTimeout;
@end
 