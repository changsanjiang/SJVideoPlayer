//
//  SJAVMediaPlayerLoader.m
//  Pods
//
//  Created by 畅三江 on 2019/4/10.
//

#import "SJAVMediaPlayerLoader.h"
#import "SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJAVMediaPlayerLoader
static void *kPlayer = &kPlayer;

+ (nullable SJAVMediaPlayer *)loadPlayerForMedia:(SJVideoPlayerURLAsset *)media {
#ifdef DEBUG
    NSParameterAssert(media);
#endif
    if ( media == nil )
        return nil;
    
    SJVideoPlayerURLAsset *target = media.original ?: media;
    SJAVMediaPlayer *__block _Nullable player = objc_getAssociatedObject(target, kPlayer);
    if ( player != nil && player.assetStatus != SJAssetStatusFailed ) {
        return player;
    }
    
    AVPlayer *avPlayer = target.avPlayer;
    if ( avPlayer == nil ) {
        AVPlayerItem *avPlayerItem = target.avPlayerItem;
        /// fix: https://github.com/changsanjiang/SJBaseVideoPlayer/pull/17 & https://github.com/changsanjiang/SJBaseVideoPlayer/issues/18
        ///      & https://github.com/changsanjiang/SJBaseVideoPlayer/pull/20/files
        /// 重新创建playerItem规避`An AVPlayerItem cannot be associated with more than one instance of AVPlayer`错误.
        /// 发现播放视频(缓冲一部分)然后断网, 出现重新播放点击后,依然会出现上述崩溃 其状态为 AVPlayerStatusReadyToPlay
        if (avPlayerItem != nil && avPlayerItem.status != AVPlayerStatusUnknown) {
            NSURL *URL = nil;
            if ( [avPlayerItem.asset isKindOfClass:AVURLAsset.class] ) {
                URL = [(AVURLAsset *)avPlayerItem.asset URL];
            }
            if ( URL == nil )
                return nil;
            avPlayerItem = [AVPlayerItem playerItemWithURL:URL];
            target.avPlayerItem = avPlayerItem;
        }
        
        if ( avPlayerItem == nil ) {
            AVAsset *avAsset = target.avAsset;
            if ( avAsset == nil ) {
                avAsset = [AVURLAsset URLAssetWithURL:target.mediaURL options:nil];
            }
            avPlayerItem = [AVPlayerItem playerItemWithAsset:avAsset];
        }
        avPlayer = [AVPlayer playerWithPlayerItem:avPlayerItem];
    }
    
    player = [SJAVMediaPlayer.alloc initWithAVPlayer:avPlayer startPosition:media.startPosition];
    objc_setAssociatedObject(target, kPlayer, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return player;
}

+ (void)clearPlayerForMedia:(SJVideoPlayerURLAsset *)media {
    if ( media != nil ) {
        id<SJMediaModelProtocol> target = media.original ?: media;
        objc_setAssociatedObject(target, kPlayer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
NS_ASSUME_NONNULL_END
