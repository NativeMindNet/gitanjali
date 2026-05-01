//
//  BUISharedAudioPlayerView.h
//  books
//
//  Created by Dmitry Panin on 22.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum 
{
	kSharedAudioPlayerViewStateShrinked,
	kSharedAudioPlayerViewStateExpanded,
	
} BUISharedAudioPlayerViewState;

@class BUISharedAudioPlayerView;

@protocol BUISharedAudioPlayerViewDelegate
- (void)sharedAudioPlayer:(BUISharedAudioPlayerView*)sender stateDidChanged:(BUISharedAudioPlayerViewState)newState;
- (void)sharedAudioPlayerPlaybackStateDidChanged:(BUISharedAudioPlayerView *)sender;
@end

@interface BUISharedAudioPlayerView : UIImageView <AVAudioPlayerDelegate>
{
	UIImage*										_upArrow;
	UIImage*										_downArrow;
	
	UIImage*										_playIcon;
	UIImage*										_playIconHighlighted;
	
	UIImage*										_pauseIcon;
	UIImage*										_pauseIconHighlighted;
	
    UIButton*										_shrinkExpandButton;
	UILabel*										_noSoundLabel;
	
	UILabel*										_leftLabel;
	UILabel*										_rightLabel;
	UILabel*										_nameLabel;
	
	UISlider*										_progressSlider;
	BOOL											_bypassSliderUpdate;
	
	UIButton*										_playPauseButton;
	
	AVAudioPlayer*									_player;
	NSTimer*										_updateTimer;
	
	BUISharedAudioPlayerViewState					_state;
	NSObject<BUISharedAudioPlayerViewDelegate>*		_delegate;
	
	BOOL											_loopingEnabled;
	UIButton*										_hideButton;
}

@property(assign)	BUISharedAudioPlayerViewState					state;
@property(assign)	NSObject<BUISharedAudioPlayerViewDelegate>*		delegate;
@property(assign)	BOOL											loopingEnabled;
@property(readonly)	BOOL											playing;
@property(readonly)	NSURL*											audioURL;

+ (BUISharedAudioPlayerView*)sharedInstance;

+ (float)shrinkedHeight;
+ (float)expandedHeight;

- (void)loadFileWithURL:(NSURL*)url name:(NSString*)name looping:(BOOL)looping;

- (void)play;
- (void)stop;

@end
