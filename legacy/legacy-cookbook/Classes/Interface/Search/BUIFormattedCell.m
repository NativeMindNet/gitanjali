//
//  BUIFormattedCell.m
//  books
//
//  Created by Dmitriy Panin on 27.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUIFormattedCell.h"
#import "BParagraphStylesStorage.h"
#import "BBookPage.h"
#import "BBookBody.h"

@implementation BUIFormattedCell

- (BParagraph*)paragraph
{
	return _paragraph;
}

- (void)setParagraph:(BParagraph *)paragraph
{
	_paragraph = paragraph;
	
	if(_paragraph)
	{
		BParagraphStyle* style = [_paragraph.page.bookBody.stylesStorage styleForName: _paragraph.styleName];
		
		if(style)
		{
			self.textLabel.font = [UIFont fontWithName:style.fontName size: style.fontSize];
			self.detailTextLabel.font = [UIFont fontWithName:style.fontName size: style.fontSize];
			self.textLabel.textColor = style.textColor;
			self.detailTextLabel.textColor = style.textColor;
			
			self.backgroundColor = style.backgroundColor;
			self.contentView.backgroundColor = style.backgroundColor;
			self.textLabel.backgroundColor = [UIColor clearColor];
			self.detailTextLabel.backgroundColor = [UIColor clearColor];
			self.accessoryView.backgroundColor = style.backgroundColor;
			self.backgroundView = [[[UIView alloc] initWithFrame: CGRectZero] autorelease];
			self.backgroundView.backgroundColor = style.backgroundColor;
		
			if(_paragraph.hidden)
			{
				self.textLabel.text = @"";
			}
			else
			{
				self.textLabel.text = paragraph.text;
			}
		}
	}
}

@end
