//
//  SJAVMediaPlayerLoader.m
//  Pods
//
//  Created by 畅三江 on 2019/4/10.
//

#import "SJAVMediaPlayerLoader.h"
#import "SJAVMediaPlayer.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJAVMediaPlayerLoader
static void *kPlayer = &kPlayer;

+ (SJAVMediaPlayer *)loadPlayerForMedia:(id<SJMediaModelProtocol>)media {
#ifdef DEBUG
    NSParameterAssert(media);
#endif
    
    id<SJMediaModelProtocol> target = media.originMedia ? : media;
    SJAVMediaPlayer *__block _Nullable player = objc_getAssociatedObject(target, kPlayer);
    BOOL able = player.sj_assetStatus != SJAssetStatusFailed;
    if ( player && able ) {
        if ( target == media && player.sj_playbackInfo.isPlayed )
            [player replay];
        
        return player;
    }
    
    AVAsset *_Nullable asset = [(id)media respondsToSelector:@selector(avAsset)]?[(id)media avAsset]:nil;
    if ( asset ) {
        player = [[SJAVMediaPlayer alloc] initWithAVAsset:asset specifyStartTime:target.specifyStartTime];
    }
    else {
        player = [[SJAVMediaPlayer alloc] initWithURL:target.mediaURL specifyStartTime:target.specifyStartTime];
    }
    
    objc_setAssociatedObject(target, kPlayer, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return player;
}

+ (void)clearPlayerForMedia:(id<SJMediaModelProtocol>)media {
    if ( media != nil ) {
        id<SJMediaModelProtocol> target = media.originMedia?:media;
        objc_setAssociatedObject(target, kPlayer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
NS_ASSUME_NONNULL_END
