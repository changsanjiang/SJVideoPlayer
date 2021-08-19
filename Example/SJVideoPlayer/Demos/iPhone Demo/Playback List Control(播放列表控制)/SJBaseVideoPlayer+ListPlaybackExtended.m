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

- (BOOL)isEqualToPlaybackItem:(SJAssetItem *)item {
    return self.id == item.id;
}
@end

@interface SJBaseVideoPlayer (ListPrivate)<SJPlaybackController>
@property (nonatomic, strong, readonly) NSHashTable<id<SJPlaybackControllerObserver>> *mPlaybackObservers;
@property (nonatomic, strong, readonly) SJPlaybackListController<SJAssetItem *> *mPlaybackListController;
@property (nonatomic, strong, nullable) SJAssetItem *currentItem;
@end

@implementation SJBaseVideoPlayer (ListPrivate)

- (SJPlaybackListController *)mPlaybackListController {
    SJPlaybackListController *mPlaybackListController = objc_getAssociatedObject(self, _cmd);
    if ( mPlaybackListController == nil ) {
        mPlaybackListController = [SJPlaybackListController.alloc initWithPlaybackController:self queue:dispatch_get_main_queue()];
        objc_setAssociatedObject(self, _cmd, mPlaybackListController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mPlaybackListController;
}

- (SJPlaybackObservation *)mPrivatePlaybackObserver {
    SJPlaybackObservation *observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [SJPlaybackObservation.alloc initWithPlayer:self];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

#pragma mark - SJPlaybackController

- (void)setCurrentItem:(nullable SJAssetItem *)currentItem {
    objc_setAssociatedObject(self, @selector(currentItem), currentItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable SJAssetItem *)currentItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)playWithItem:(SJAssetItem *)item {
    SJVideoPlayerURLAsset *asset = [self.assetProvider videoPlayer:self assetAtIndex:item.id];
    self.URLAsset = asset;
}

- (void)registerObserver:(id<SJPlaybackControllerObserver>)observer {
    if ( observer != nil ) {
        [self.mPlaybackObservers addObject:observer];
        
        SJPlaybackObservation *finishPlayingObserver = objc_getAssociatedObject(self, _cmd);
        if ( finishPlayingObserver == nil ) {
            finishPlayingObserver = [SJPlaybackObservation.alloc initWithPlayer:self];
            finishPlayingObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                if ( player.mPlaybackObservers.count != 0 ) {
                    for ( id<SJPlaybackControllerObserver> observer in player.mPlaybackObservers ) {
                        [observer playbackControllerDidFinishPlaying:player];
                    }
                }
            };
            objc_setAssociatedObject(self, _cmd, finishPlayingObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (void)removeObserver:(id<SJPlaybackControllerObserver>)observer {
    [self.mPlaybackObservers removeObject:observer];
}

- (NSHashTable<id<SJPlaybackControllerObserver>> *)mPlaybackObservers {
    NSHashTable<id<SJPlaybackControllerObserver>> *observers = objc_getAssociatedObject(self, _cmd);
    if ( observers == nil ) {
        observers = NSHashTable.weakObjectsHashTable;
        objc_setAssociatedObject(self, _cmd, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observers;
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
    [self.mPlaybackListController replaceItemsFromArray:m];
}

- (NSInteger)numberOfAssets {
    return self.mPlaybackListController.numberOfItems;
}

- (NSInteger)currentAssetIndex {
    return self.mPlaybackListController.curIndex;
}

- (void)playPreviousAsset {
    [self.mPlaybackListController playPreviousItem];
}

- (void)playNextAsset {
    [self.mPlaybackListController playNextItem];
}

- (void)playAtIndex:(NSInteger)index {
    [self.mPlaybackListController playItemAtIndex:index];
}
@end
