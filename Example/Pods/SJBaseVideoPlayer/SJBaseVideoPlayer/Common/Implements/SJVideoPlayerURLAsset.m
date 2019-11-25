//
//  SJVideoPlayerURLAsset.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"
#import <objc/message.h>
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAssetObserver : NSObject<SJVideoPlayerURLAssetObserver>
- (instancetype)initWithAsset:(SJVideoPlayerURLAsset *)asset;
@end
@implementation SJVideoPlayerURLAssetObserver
@synthesize playModelDidChangeExeBlock = _playModelDidChangeExeBlock;

- (instancetype)initWithAsset:(SJVideoPlayerURLAsset *)asset {
    self = [super init];
    if ( !self ) return nil;
    [asset sj_addObserver:self forKeyPath:@"playModel"];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( _playModelDidChangeExeBlock ) _playModelDidChangeExeBlock(object);
}
@end

@implementation SJVideoPlayerURLAsset
@synthesize mediaURL = _mediaURL; 

- (nullable instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel {
    if ( !URL ) return nil;
    self = [super init];
    if ( !self ) return nil;
    _mediaURL = URL;
    _specifyStartTime = specifyStartTime;
    _playModel = playModel?:[SJPlayModel new];
    return self;
}
- (nullable instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithURL:URL specifyStartTime:specifyStartTime playModel:[SJPlayModel new]];
}
- (nullable instancetype)initWithURL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithURL:URL specifyStartTime:0 playModel:playModel];
}
- (nullable instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL specifyStartTime:0];
}
- (nullable instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset playModel:(nullable __kindof SJPlayModel *)playModel {
    if ( !otherAsset ) return nil;
    self = [super init];
    if ( !self ) return nil;
    SJVideoPlayerURLAsset *curr = otherAsset;
    while ( curr.originAsset != nil && curr != curr.originAsset ) {
        curr = curr.originAsset;
    }
    _originAsset = curr;
    _mediaURL = curr.mediaURL;
    _playModel = playModel?:[SJPlayModel new];
    return self;
} 
- (BOOL)isM3u8 {
    return [_mediaURL.pathExtension containsString:@"m3u8"];
} 
- (SJPlayModel *)playModel {
    if ( _playModel )
        return _playModel;
    return _playModel = [SJPlayModel new];
}
- (id<SJVideoPlayerURLAssetObserver>)getObserver {
    return [[SJVideoPlayerURLAssetObserver alloc] initWithAsset:self];
}
- (nullable id<SJMediaModelProtocol>)originMedia {
    return _originAsset;
}
@end
NS_ASSUME_NONNULL_END
