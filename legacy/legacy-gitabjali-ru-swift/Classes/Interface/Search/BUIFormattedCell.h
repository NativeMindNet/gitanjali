//
//  BUIFormattedCell.h
//  books
//
//  Created by Dmitriy Panin on 27.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#include "BParagraph.h"

@interface BUIFormattedCell : UITableViewCell
{
	BParagraph* _paragraph;
}

@property(assign) BParagraph* paragraph;

@end
