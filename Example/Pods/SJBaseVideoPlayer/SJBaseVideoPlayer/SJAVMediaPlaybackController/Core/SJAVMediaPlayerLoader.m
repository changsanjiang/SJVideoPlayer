//
//  SJAVMediaPlayerLoader.m
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import "SJAVMediaPlayerLoader.h"
#import "SJAVMediaPlayer.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJAVMediaPlayerLoader
static void *kPlayer = &kPlayer;

+ (void)loadPlayerForMedia:(id<SJMediaModelProtocol>)media completionHandler:(void(^_Nullable)(id<SJMediaModelProtocol> media, id<SJAVMediaPlayerProtocol> player))completionHandler {
    if ( media == nil )
        return;
    
    id<SJMediaModelProtocol> target = media.originMedia?:media;
    SJAVMediaPlayer *__block _Nullable player = objc_getAssociatedObject(target, kPlayer);
    SJVideoPlayerInactivityReason inactivityReason = player.sj_inactivityReason;
    BOOL able = inactivityReason != SJVideoPlayerInactivityReasonPlayFailed;
    if ( player && able ) {
        if ( target == media && [player sj_getIsPlayed] )
            [player reset];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler ) completionHandler(media, player);
        });
        return;
    }
    
    AVAsset *_Nullable asset = [(id)media respondsToSelector:@selector(avAsset)]?[(id)media avAsset]:nil;
    if ( asset ) {
        player = [[SJAVMediaPlayer alloc] initWithAVAsset:asset specifyStartTime:target.specifyStartTime];
    }
    else {
        player = [[SJAVMediaPlayer alloc] initWithURL:target.mediaURL specifyStartTime:target.specifyStartTime];
    }
    
    objc_setAssociatedObject(target, kPlayer, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( completionHandler ) completionHandler(media, player);
    });
}

+ (void)clearPlayerForMedia:(id<SJMediaModelProtocol>)media {
    if ( media != nil ) {
        id<SJMediaModelProtocol> target = media.originMedia?:media;
        objc_setAssociatedObject(target, kPlayer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
NS_ASSUME_NONNULL_END
