//
//  SJIJKMediaPlaybackController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJIJKMediaPlaybackController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaPlaybackController ()

@end

@implementation SJIJKMediaPlaybackController
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize periodicTimeInterval = _periodicTimeInterval;
@synthesize delegate = _delegate;
@synthesize volume = _volume;
@synthesize rate = _rate;
@synthesize muted = _muted;
@synthesize media = _media;
@synthesize assetStatus;
@synthesize currentTime;
@synthesize duration;
@synthesize durationWatched;
@synthesize error;
@synthesize isPlayed;
@synthesize isPlayedToEndTime;
@synthesize playableDuration;
@synthesize playbackType;
@synthesize playerView;
@synthesize presentationSize;
@synthesize readyForDisplay;
@synthesize reasonForWaitingToPlay;
@synthesize replayed;
@synthesize timeControlStatus;
@synthesize videoGravity;

- (void)pause {
        
}

- (void)play {
        
}

- (void)prepareToPlay {
    
}

- (void)refresh {
    
}

- (void)replay {
    
}

- (nullable UIImage *)screenshot {
    return nil;
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    
}

- (void)stop {
    
}

- (void)switchVideoDefinition:(nonnull id<SJMediaModelProtocol>)media {
    
}
@end
NS_ASSUME_NONNULL_END
