//
//  SJBaseVideoPlayer+ListPlaybackExtended.m
//  SJVideoPlayer_Example
//
//  Created by BD on 2021/3/13.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import "SJBaseVideoPlayer+ListPlaybackExtended.h"
#import <objc/message.h>
#import <SJPlaybackListController/SJPlaybackListController.h>

@interface SJAssetItem : NSObject<SJMediaInfo>
- (instancetype)initWithIdx:(NSInteger)idx;
@property (nonatomic, readonly) NSInteger id;
@end

@implementation SJAssetItem
- (instancetype)initWithIdx:(NSInteger)idx {
    self = [super init];
    if ( self ) {
        _id = idx;
    }
    return self;
}
@end

@interface SJBaseVideoPlayer (ListPrivate)<SJPlaybackListControllerDelegate>
@property (nonatomic, strong, readonly) SJPlaybackListController *listController;
@property (nonatomic, strong, readonly) SJPlaybackObservation *mPrivatePlaybackObserver;
@end

@implementation SJBaseVideoPlayer (ListPrivate)
- (SJPlaybackListController *)listController {
    SJPlaybackListController *listController = objc_getAssociatedObject(self, _cmd);
    if ( listController == nil ) {
        listController = SJPlaybackListController.alloc.init;
        listController.delegate = self;
        objc_setAssociatedObject(self, _cmd, listController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return listController;
}

- (SJPlaybackObservation *)mPrivatePlaybackObserver {
    SJPlaybackObservation *observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [SJPlaybackObservation.alloc initWithPlayer:self];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)listController:(id<SJPlaybackListController>)listController needToPlayMedia:(id<SJMediaInfo>)media {
    SJVideoPlayerURLAsset *asset = [self.assetProvider videoPlayer:self assetAtIndex:media.id];
    self.URLAsset = asset;
}

- (void)listController:(id<SJPlaybackListController>)listController needToReplayCurrentMedia:(id<SJMediaInfo>)media {
    [self replay];
}

- (void)currentMediaForListControllerIsRemoved:(id<SJPlaybackListController>)listController { }

@end

@interface SJBaseVideoPlayerAssetProviderWeak : NSObject
@property (nonatomic, weak, nullable) id<SJBaseVideoPlayerAssetProvider> assetProvider;
@end

@implementation SJBaseVideoPlayerAssetProviderWeak

@end

@implementation SJBaseVideoPlayer (ListPlaybackExtended)

- (void)setAssetProvider:(id<SJBaseVideoPlayerAssetProvider>)assetProvider {
    SJBaseVideoPlayerAssetProviderWeak *weak = SJBaseVideoPlayerAssetProviderWeak.alloc.init;
    weak.assetProvider = assetProvider;
    objc_setAssociatedObject(self, @selector(assetProvider), weak, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable id<SJBaseVideoPlayerAssetProvider>)assetProvider {
    SJBaseVideoPlayerAssetProviderWeak *weak = objc_getAssociatedObject(self, _cmd);
    return weak.assetProvider;
}

- (void)setNumberOfAssets:(NSInteger)numberOfAssets {
    [self.listController removeAllMedias];
    NSMutableArray<SJAssetItem *> *m = [NSMutableArray arrayWithCapacity:numberOfAssets];
    for ( int i = 0 ; i < numberOfAssets ; ++ i ) {
        SJAssetItem *item = [SJAssetItem.alloc initWithIdx:i];
        [m addObject:item];
    }
    [self.listController addMedias:m];
    
    if ( self.mPrivatePlaybackObserver.playbackDidFinishExeBlock == nil ) {
        self.mPrivatePlaybackObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            [player.listController currentMediaFinishedPlaying];
        };
    }
}

- (NSInteger)numberOfAssets {
    return self.listController.medias.count;
}

- (NSInteger)currentAssetIndex {
    return self.listController.currentMedia.id;
}

- (void)playPreviousAsset {
    [self.listController playPreviousMedia];
}

- (void)playNextAsset {
    [self.listController playNextMedia];
}

- (void)playAtIndex:(NSInteger)index {
    [self.listController playAtIndex:index];
}
@end
