//
//  BUIControl.h
//  books
//
//  Created by Dmitriy Panin on 10.08.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BControlInfo.h"

extern NSString* BUIControlDidPressedNotification;
extern NSString* BUIControlTypeKey;
extern NSString* BUIControlInfoKey;

@interface BUIControl : UIView
{
	UIButton*		_btn;
	BControlInfo*	_info;
	BControlType	_type;
	BControlState	_state;
	
	UIPanGestureRecognizer*			_panGestureRecognizer;
	UILongPressGestureRecognizer*	_longPressGestureRecognizer;
	BOOL							_dragging;
}

@property(readonly) BControlType	type;
@property(assign)	BOOL			enabled;
@property(readonly)	BControlInfo*	controlInfo;
@property(readonly)	BControlState	state;
@property(readonly)	BOOL			dragging;

- (id)initWithControlInfo:(BControlInfo*)info;

@end
