//
//  SJAVMediaPlayer.h
//  Pods
//
//  Created by 畅三江 on 2020/2/18.
//

#import "SJMediaPlaybackController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayer : NSObject<SJMediaPlayer>
- (instancetype)initWithAVPlayer:(AVPlayer *)player startPosition:(NSTimeInterval)time;

@property (nonatomic) NSTimeInterval trialEndPosition;
@property (nonatomic, strong, readonly) AVPlayer *avPlayer;
@property (nonatomic, readonly) SJPlaybackType playbackType;
@property (nonatomic) NSTimeInterval minBufferedDuration;
@property (nonatomic) BOOL accurateSeeking;

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler;
@end
NS_ASSUME_NONNULL_END
