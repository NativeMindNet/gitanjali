//
//  BUISharedAudioPlayerView.m
//  books
//
//  Created by Dmitry Panin on 22.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BUISharedAudioPlayerView.h"

@interface BUISharedAudioPlayerView(Private)
- (void)_onShrinkExpandButton;
- (void)_updateControls;
- (void)_updateSlider;
- (NSString*)_timeString:(float)time;
- (void)_onButton;
- (void)_onUpdateTimer;
- (void)_onSliderValueChanged;
- (void)_onLoopButton;
@end


@implementation BUISharedAudioPlayerView

@synthesize delegate = _delegate;

- (BOOL)playing
{
	return  _player.playing;
}

- (NSURL*)audioURL
{
	return _player.url;
}

- (BUISharedAudioPlayerViewState)state
{
	return _state;
}

- (void)setState:(BUISharedAudioPlayerViewState)state
{
	_state = state;
	
	if(_state == kSharedAudioPlayerViewStateShrinked)
	{
		[_shrinkExpandButton setImage:_upArrow forState: UIControlStateNormal];
	}
	else
	{
		[_shrinkExpandButton setImage:_downArrow forState: UIControlStateNormal];
	}
	
	if([_delegate respondsToSelector:@selector(sharedAudioPlayer:stateDidChanged:)])
	{
		[_delegate sharedAudioPlayer:self stateDidChanged: _state];
	}
}

- (BOOL)loopingEnabled
{
	return _loopingEnabled;
}

- (void)setLoopingEnabled:(BOOL)loopingEnabled
{
	_loopingEnabled = loopingEnabled;
	
	if(_loopingEnabled)
	{
		_player.numberOfLoops = -1;
	}
	else
	{
		_player.numberOfLoops = 0;
	}
}

- (void)dealloc
{
	[_hideButton release];
	[_leftLabel release];
	[_rightLabel release];
	[_nameLabel release];
	
	[_playIcon release];
	[_playIconHighlighted release];
	
	[_pauseIcon release];
	[_pauseIconHighlighted release];
	
	[_progressSlider release];
	
	[_playPauseButton release];
	
	[_player stop];
	[_updateTimer invalidate];
	
	[_noSoundLabel release];
	[_upArrow release];
	[_downArrow release];
	[_shrinkExpandButton release];
	
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame: frame]))
	{
		UIImage* backgroundImage = [UIImage imageNamed: @"player_background.png"];
		self.image = backgroundImage;
		self.contentMode = UIViewContentModeScaleToFill;
		self.userInteractionEnabled = YES;
		
//		_upArrow = [[UIImage imageNamed: @"up-arrow.png"] retain];
		_downArrow = [[UIImage imageNamed: @"down-arrow.png"] retain];

		_playIcon = [[UIImage imageNamed: @"play_c.png"] retain];
		_playIconHighlighted = [[UIImage imageNamed: @"play_c_h.png"] retain];
		
		_pauseIcon = [[UIImage imageNamed: @"pause_c.png"] retain];
		_pauseIconHighlighted = [[UIImage imageNamed: @"pause_c_h.png"] retain];
		
//removed by request
//		
//		_shrinkExpandButton = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
//		_shrinkExpandButton.center = CGPointMake(self.bounds.size.width / 2.0f,  10.0f);
//		
//		_shrinkExpandButton.bounds = CGRectMake(0.0f, 0.0f, _upArrow.size.width + 40, _upArrow.size.height + 40);
//		[_shrinkExpandButton setImage:_upArrow forState: UIControlStateNormal];
//		[_shrinkExpandButton addTarget:self
//								action:@selector(_onShrinkExpandButton) 
//					  forControlEvents: UIControlEventTouchUpInside];
//		
//		_shrinkExpandButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//		_shrinkExpandButton.enabled = NO;
//		
//		[self addSubview: _shrinkExpandButton];
		
		_noSoundLabel = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 0.0f, self.bounds.size.width,  [[self class] expandedHeight])];
		_noSoundLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_noSoundLabel.backgroundColor = [UIColor clearColor];
		_noSoundLabel.textColor = [UIColor grayColor];
//		_noSoundLabel.shadowColor = [UIColor darkGrayColor];
//		_noSoundLabel.shadowOffset = CGSizeMake(0, 1);
		_noSoundLabel.textAlignment = UITextAlignmentCenter;
		_noSoundLabel.text = @"No Sound is loaded. Click on play button.";
		[self addSubview: _noSoundLabel];
		
		//
		_playPauseButton = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
		_playPauseButton.frame = CGRectMake(10.0f, 10.0f, 50.0f, 50.0f);
		[_playPauseButton addTarget: self 
							 action: @selector(_onButton) 
				   forControlEvents: UIControlEventTouchUpInside];
		
		[self addSubview: _playPauseButton];
		
		_progressSlider = [[UISlider alloc] initWithFrame: CGRectMake(70.0f, 30.0f, self.bounds.size.width - 90.0f - 10.0f, 0)];
		_progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_progressSlider.continuous = NO;
		[_progressSlider addTarget: self 
							action: @selector(_onSliderValueChanged) forControlEvents: UIControlEventValueChanged];
		
		_nameLabel = [[UILabel alloc] initWithFrame: CGRectMake(70.0f, 10.0f, self.bounds.size.width - 90.0f - 10.0f - 80, 20.0f)];
		_nameLabel.textAlignment = UITextAlignmentLeft;
		_nameLabel.font = [UIFont boldSystemFontOfSize: 14.0f];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.textColor = [UIColor grayColor];
		_nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubview: _nameLabel];
		
		_hideButton = [UIButton buttonWithType: UIButtonTypeCustom];
		_hideButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_hideButton addTarget:self 
						action:@selector(_onHideButton) 
			  forControlEvents: UIControlEventTouchUpInside];
		
		_hideButton.center = CGPointMake(self.bounds.size.width / 2.0f,  10.0f);
		_hideButton.bounds = CGRectMake(0.0f, 0.0f, _downArrow.size.width + 40, _downArrow.size.height + 40);
		[_hideButton setImage: _downArrow forState: UIControlStateNormal];

		[self addSubview: _hideButton];
		
		_leftLabel = [[UILabel alloc] initWithFrame: CGRectMake(70.0f, 50.0f, 70.0f, 20.0f)];
		_leftLabel.textAlignment = UITextAlignmentLeft;
		_leftLabel.font = [UIFont systemFontOfSize: 12.0f];
		_leftLabel.backgroundColor = [UIColor clearColor];
		_leftLabel.textColor = [UIColor grayColor];
		[self addSubview: _leftLabel];
		
		_rightLabel = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(_progressSlider.frame) - 70.0f, 50.0f, 70.0f, 20.0f)];
		_rightLabel.textAlignment = UITextAlignmentRight;
		_rightLabel.font = [UIFont systemFontOfSize: 12.0f];
		_rightLabel.backgroundColor = [UIColor clearColor];
		_rightLabel.textColor = [UIColor grayColor];
		_rightLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[self addSubview: _rightLabel];
		[self addSubview: _progressSlider];
		
		[self _updateControls];
	}
	
	return self;
}

+ (BUISharedAudioPlayerView*)sharedInstance
{
	static BUISharedAudioPlayerView* sharedInstance = nil;
	
	if(!sharedInstance)
	{
		CGRect frame;
		frame.origin = CGPointZero;
		frame.size = CGSizeMake(768, [[self class] shrinkedHeight]);
		sharedInstance = [[BUISharedAudioPlayerView alloc] initWithFrame: frame];
	}
	
	return sharedInstance;
}

+ (float)shrinkedHeight
{
	return 0.0f;
}

+ (float)expandedHeight
{
	return  70.0;
}

- (void)loadFileWithURL:(NSURL*)url name:(NSString*)name looping:(BOOL)looping
{
	self.loopingEnabled = looping;
	
	if(_player)
	{
		NSString* currentURL = [_player.url absoluteString];
		NSString* desiredURL = [url absoluteString];
		
		if([currentURL isEqualToString: desiredURL])
		{
			_nameLabel.text = name;
			[self _updateControls];
			return;
		}
		
		[_player stop];
		[_player release];
		_player = nil;
	}
	
	@try 
	{
		_player = [[AVAudioPlayer alloc] initWithContentsOfURL: url error: nil];
		_player.delegate = self;
		[_player prepareToPlay];
		
		if(_loopingEnabled)
		{
			_player.numberOfLoops = -1;
		}
	}
	@catch (NSException *exception) 
	{
		
	}

	_nameLabel.text = name;
	
	[self _updateControls];
}

- (void)play
{
	[_player play];
	[self _updateControls];
	
	if([_delegate respondsToSelector: @selector(sharedAudioPlayerPlaybackStateDidChanged:)])
	{
		[_delegate sharedAudioPlayerPlaybackStateDidChanged: self];
	}
}

- (void)stop
{
	[_player pause];
	[self _updateControls];
	
	if([_delegate respondsToSelector: @selector(sharedAudioPlayerPlaybackStateDidChanged:)])
	{
		[_delegate sharedAudioPlayerPlaybackStateDidChanged: self];
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if([_delegate respondsToSelector: @selector(sharedAudioPlayerPlaybackStateDidChanged:)])
	{
		[_delegate sharedAudioPlayerPlaybackStateDidChanged: self];
	}
}

- (void)_onShrinkExpandButton
{
	if(_state == kSharedAudioPlayerViewStateShrinked)
	{
		_state = kSharedAudioPlayerViewStateExpanded;
		[_shrinkExpandButton setImage:_downArrow forState: UIControlStateNormal];
	}
	else
	{
		_state = kSharedAudioPlayerViewStateShrinked;
		[_shrinkExpandButton setImage:_upArrow forState: UIControlStateNormal];
	}
	
	if([_delegate respondsToSelector:@selector(sharedAudioPlayer:stateDidChanged:)])
	{
		[_delegate sharedAudioPlayer:self stateDidChanged: _state];
	}
}

- (void)_updateControls
{
	if(_player)
	{
		_noSoundLabel.hidden = YES;
		
		_leftLabel.hidden = NO;
		_rightLabel.hidden = NO;
		_progressSlider.hidden = NO;
		_playPauseButton.hidden = NO;
		_nameLabel.hidden = NO;
		
		_shrinkExpandButton.enabled = YES;
		_hideButton.hidden = NO;
	}
	else
	{
		_noSoundLabel.hidden = NO;
		
		_leftLabel.hidden = YES;
		_rightLabel.hidden = YES;
		_progressSlider.hidden = YES;
		_playPauseButton.hidden = YES;	
		_nameLabel.hidden = YES;
		_hideButton.hidden = NO;
		
		if(_state == kSharedAudioPlayerViewStateShrinked)
		{
			_shrinkExpandButton.enabled = NO;
		}
		else
		{
			_shrinkExpandButton.enabled = YES;
		}
	}
	
	if(_player.playing)
	{
		[_playPauseButton setImage:_pauseIcon forState: UIControlStateNormal];
		[_playPauseButton setImage:_pauseIconHighlighted forState: UIControlStateHighlighted];
		
		if(!_updateTimer)
		{
			_updateTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1f 
															target: self 
														  selector: @selector(_onUpdateTimer) 
														  userInfo: self 
														   repeats: YES];
		}
	}
	else 
	{
		[_playPauseButton setImage:_playIcon forState: UIControlStateNormal];
		[_playPauseButton setImage:_playIconHighlighted forState: UIControlStateHighlighted];
		
		if(_updateTimer)
		{
			[_updateTimer invalidate];
			_updateTimer = nil;
		}
	}
	
	[self _updateSlider];

}

- (void)_updateSlider
{
	if(!_progressSlider.tracking)
	{
		_progressSlider.value = _player.currentTime / (_player.duration + 0.001f);
		_leftLabel.text = [self _timeString: _player.currentTime];
		_rightLabel.text = [NSString stringWithFormat: @"-%@", [self _timeString: fabsf(_player.duration - _player.currentTime)]];
	}
}

- (NSString*)_timeString:(float)timef
{
	int time = timef;
	
	return [NSString stringWithFormat: @"%d:%.2d", time / 60, time % 60];
}	

- (void)_onButton
{
	if(_player.playing)
	{
		[_player stop];
	}
	else 
	{
		[_player play];
	}
	
	[self _updateControls];
	
}

- (void)_onUpdateTimer
{
	[self _updateSlider];
	
	if(!_player.playing)
	{
		[self _updateControls];
	}
}

- (void)_onSliderValueChanged
{
	_player.currentTime = _progressSlider.value * _player.duration;
	[self _updateSlider];
}

- (void)_onHideButton
{
	[self setState: kSharedAudioPlayerViewStateShrinked];
}

@end
