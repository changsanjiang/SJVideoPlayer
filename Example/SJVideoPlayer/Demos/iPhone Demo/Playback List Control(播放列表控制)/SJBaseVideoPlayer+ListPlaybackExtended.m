//
//  SJBaseVideoPlayer+ListPlaybackExtended.m
//  SJVideoPlayer_Example
//
//  Created by BD on 2021/3/13.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import "SJBaseVideoPlayer+ListPlaybackExtended.h"
#import <objc/message.h>
#import <SJUIKit/SJPlaybackListController.h>

@interface SJAssetItem : NSObject<SJPlaybackItem>
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

- (id)itemKey {
    return @(_id);
}
@end

@interface SJBaseVideoPlayer (ListPrivate)<SJPlaybackController>
@property (nonatomic, strong, readonly) SJPlaybackListController<SJAssetItem *> *listController;
@property (nonatomic, copy, nullable) SJPlaybackCompletionHandler playbackCompletionHandler;
@property (nonatomic, strong, readonly) SJPlaybackObservation *mPrivatePlaybackObserver;
@property (nonatomic, strong, nullable) SJAssetItem *curItem;
@end

@implementation SJBaseVideoPlayer (ListPrivate)
- (SJPlaybackListController *)listController {
    SJPlaybackListController *listController = objc_getAssociatedObject(self, _cmd);
    if ( listController == nil ) {
        listController = [SJPlaybackListController.alloc initWithPlaybackController:self];
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
 
- (void)setPlaybackCompletionHandler:(nullable SJPlaybackCompletionHandler)playbackCompletionHandler {
    objc_setAssociatedObject(self, @selector(playbackCompletionHandler), playbackCompletionHandler, OBJC_ASSOCIATION_COPY);
}

- (nullable SJPlaybackCompletionHandler)playbackCompletionHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCurItem:(nullable SJAssetItem *)curItem {
    objc_setAssociatedObject(self, @selector(curItem), curItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable SJAssetItem *)curItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)playWithItem:(SJAssetItem *)item {
    SJVideoPlayerURLAsset *asset = [self.assetProvider videoPlayer:self assetAtIndex:item.id];
    self.URLAsset = asset;
}
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
    NSMutableArray<SJAssetItem *> *m = [NSMutableArray arrayWithCapacity:numberOfAssets];
    for ( int i = 0 ; i < numberOfAssets ; ++ i ) {
        SJAssetItem *item = [SJAssetItem.alloc initWithIdx:i];
        [m addObject:item];
    }
    [self.listController removeAllItems];
    [self.listController addItemsFromArray:m];
    
    if ( self.mPrivatePlaybackObserver.playbackDidFinishExeBlock == nil ) {
        self.mPrivatePlaybackObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            if ( player.playbackCompletionHandler ) player.playbackCompletionHandler();
        };
    }
}

- (NSInteger)numberOfAssets {
    return self.listController.numberOfItems;
}

- (NSInteger)currentAssetIndex {
    return self.listController.curIndex;
}

- (void)playPreviousAsset {
    [self.listController playPreviousItem];
}

- (void)playNextAsset {
    [self.listController playNextItem];
}

- (void)playAtIndex:(NSInteger)index {
    [self.listController playItemAtIndex:index];
}
@end
