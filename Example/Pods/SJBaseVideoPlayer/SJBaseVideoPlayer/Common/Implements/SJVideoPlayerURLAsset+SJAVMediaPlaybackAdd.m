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
    return [self initWithAVAsset:asset specifyStartTime:0 playModel:playModel];
}
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel {
    if ( asset == nil ) return nil;
    self = [super init];
    if ( !self ) return nil;
    self.specifyStartTime = specifyStartTime;
    self.playModel = playModel;
    self.avAsset = asset;
    return self;
}
- (void)setAvAsset:(__kindof AVAsset * _Nullable)avAsset {
    objc_setAssociatedObject(self, @selector(avAsset), avAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVAsset *)avAsset {
    return objc_getAssociatedObject(self, _cmd);
}
@end
NS_ASSUME_NONNULL_END
