//
//  SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.m
//  Project
//
//  Created by 畅三江 on 2018/8/12.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerURLAsset (SJAVMediaPlaybackAdd)
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset {
    return [self initWithAVAsset:asset playModel:[SJPlayModel new]];
}
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithAVAsset:asset startPosition:0 playModel:playModel];
}
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel {
    if ( asset == nil ) return nil;
    self = [super init];
    if ( self ) {
        self.avAsset = asset;
        self.playModel = playModel;
        self.startPosition = startPosition;
    }
    return self;
}

- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem {
    return [self initWithAVPlayerItem:playerItem playModel:SJPlayModel.new];
}
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithAVPlayerItem:playerItem startPosition:0 playModel:playModel];
}
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel {
    if ( playerItem == nil ) return nil;
    self = [super init];
    if ( self ) {
        self.avPlayerItem = playerItem;
        self.playModel = playModel;
        self.startPosition = startPosition;
    }
    return self;
}

- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player {
    return [self initWithAVPlayer:player playModel:SJPlayModel.new];
}
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithAVPlayer:player startPosition:0 playModel:SJPlayModel.new];
}
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel {
    if ( player == nil ) return nil;
    self = [super init];
    if ( self ) {
        self.avPlayer = player;
        self.playModel = playModel;
        self.startPosition = startPosition;
    }
    return self;
}
- (void)setAvAsset:(__kindof AVAsset * _Nullable)avAsset {
    objc_setAssociatedObject(self, @selector(avAsset), avAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable __kindof AVAsset *)avAsset {
    if ( self.original != nil ) return self.original.avAsset;
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAvPlayerItem:(AVPlayerItem * _Nullable)avPlayerItem {
    objc_setAssociatedObject(self, @selector(avPlayerItem), avPlayerItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVPlayerItem *)avPlayerItem {
    if ( self.original != nil ) return self.original.avPlayerItem;
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAvPlayer:(AVPlayer * _Nullable)avPlayer {
    objc_setAssociatedObject(self, @selector(avPlayer), avPlayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVPlayer *)avPlayer {
    if ( self.original != nil ) return self.original.avPlayer;
    return objc_getAssociatedObject(self, _cmd);
}

- (nullable instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset playModel:(nullable __kindof SJPlayModel *)playModel {
    if ( !otherAsset ) return nil;
    self = [super init];
    if ( self ) {
        SJVideoPlayerURLAsset *curr = otherAsset;
        while ( curr.original != nil && curr != curr.original ) {
            curr = curr.original;
        }
        self.original = curr;
        self.mediaURL = curr.mediaURL;
        self.playModel = playModel?:[SJPlayModel new];
    }
    return self;
}

- (void)setOriginal:(SJVideoPlayerURLAsset * _Nullable)original {
    objc_setAssociatedObject(self, @selector(original), original, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJVideoPlayerURLAsset *)original {
    return objc_getAssociatedObject(self, _cmd);
}
- (nullable SJVideoPlayerURLAsset *)originAsset __deprecated_msg("ues `original`") {
    return self.original;
}
@end
NS_ASSUME_NONNULL_END
