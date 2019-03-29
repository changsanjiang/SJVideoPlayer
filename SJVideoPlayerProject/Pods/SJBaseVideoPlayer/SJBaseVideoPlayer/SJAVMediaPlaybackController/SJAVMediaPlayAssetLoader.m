//
//  SJAVMediaPlayAssetLoader.m
//  Pods
//
//  Created by 畅三江 on 2019/1/13.
//

#import "SJAVMediaPlayAssetLoader.h"
#import <objc/message.h>
#import "SJAVMediaPlayAsset.h"
#import "SJAVMediaModelProtocol.h"
#import "SJMediaPlaybackProtocol.h"

NS_ASSUME_NONNULL_BEGIN
static const char key;

SJAVMediaPlayAsset *
sj_assetForMedia(id<SJMediaModelProtocol> media) {
    id<SJMediaModelProtocol> _Nullable other = media.otherMedia;
    id<SJMediaModelProtocol> target = other?:media;
    SJAVMediaPlayAsset *_Nullable playAsset = objc_getAssociatedObject(target, &key);
    if ( !playAsset || (AVPlayerStatusFailed == playAsset.playerItemStatus) ) {
        AVAsset *_Nullable asset = [(id)media respondsToSelector:@selector(avAsset)]?[(id)media avAsset]:nil;
        if ( asset )
            /// create by AVAsset
            playAsset = [[SJAVMediaPlayAsset alloc] initWithAVAsset:asset specifyStartTime:media.specifyStartTime];
        else
            /// create by URL
            playAsset = [[SJAVMediaPlayAsset alloc] initWithURL:media.mediaURL specifyStartTime:media.specifyStartTime];
        objc_setAssociatedObject(target, &key, playAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return playAsset;
}

void
sj_removeAssetForMedia(id<SJMediaModelProtocol> _Nullable media) {
    if ( !media )
        return;
    id<SJMediaModelProtocol> _Nullable other = media.otherMedia;
    id<SJMediaModelProtocol> target = other?:media;
    objc_setAssociatedObject(target, &key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@interface SJAVMediaAssetLoader ()<SJAVMediaPlayAssetPropertiesObserverDelegate>
@property (nonatomic, copy, readonly) SJAVMediaLoadStatusDidChangeHandler handler;
@property (nonatomic, strong, readonly) SJAVMediaPlayAssetPropertiesObserver *observer;
@end

@implementation SJAVMediaAssetLoader
- (instancetype)initWithAsset:(SJAVMediaPlayAsset *)asset
          loadStatusDidChange:(SJAVMediaLoadStatusDidChangeHandler)handler {
    self = [super init];
    if ( !self ) return nil;
    _asset = asset;
    _handler = handler;
    _observer = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:asset];
    _observer.delegate = self;
    return self;
}
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
    if ( _handler ) _handler(self.asset.playerItemStatus);
}
@end
NS_ASSUME_NONNULL_END
