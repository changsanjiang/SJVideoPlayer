//
//  SJVideoPlayerURLAsset.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 SanJiang. All rights reserved.
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

- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel {
    self = [super init];
    if ( !self ) return nil;
    _mediaURL = URL;
    _specifyStartTime = specifyStartTime;
    _playModel = playModel?:[SJPlayModel new];
    return self;
}
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithURL:URL specifyStartTime:specifyStartTime playModel:[SJPlayModel new]];
}
- (instancetype)initWithURL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithURL:URL specifyStartTime:0 playModel:playModel];
}
- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL specifyStartTime:0];
}
- (instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset playModel:(nullable __kindof SJPlayModel *)playModel {
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



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation SJVideoPlayerURLAsset (Deprecated)
- (instancetype)initWithAssetURL:(NSURL *)assetURL __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithAssetURL:assetURL beginTime:0];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithURL:assetURL specifyStartTime:beginTime];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithAssetURL:assetURL beginTime:0 scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime // unit is sec.
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    SJPlayModel *playModel = nil;
    if( [scrollView isKindOfClass:[UITableView class]] ) {
        playModel = [[SJUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath tableView:(id)scrollView];
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        playModel = [[SJUICollectionViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionView:(id)scrollView];
    }
    return [self initWithURL:assetURL specifyStartTime:beginTime playModel:playModel];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithAssetURL:assetURL beginTime:0 playerSuperViewOfTableHeader:superView tableView:tableView];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithURL:assetURL specifyStartTime:beginTime playModel:[[SJUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperview:superView tableView:tableView]];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
     collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
         collectionCellIndexPath:(NSIndexPath *)indexPath
              playerSuperViewTag:(NSInteger)playerSuperViewTag
                   rootTableView:(UITableView *)rootTableView __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithURL:assetURL specifyStartTime:beginTime playModel:[[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperviewTag:playerSuperViewTag atIndexPath:indexPath collectionView:collectionView tableView:rootTableView]];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime // unit is sec.
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView __deprecated_msg("已弃用, 请使用 `initWithURL:playModel:`;") {
    return [self initWithURL:assetURL specifyStartTime:beginTime playModel:[[SJUICollectionViewNestedInUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionViewTag:scrollViewTag collectionViewAtIndexPath:scrollViewIndexPath tableView:(id)rootScrollView]];
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    return [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:asset playModel:nil];
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                         scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                          indexPath:(NSIndexPath * __nullable)indexPath
                       superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    SJPlayModel *playModel = nil;
    if( [scrollView isKindOfClass:[UITableView class]] ) {
        playModel = [[SJUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath tableView:(id)scrollView];
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        playModel = [[SJUICollectionViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionView:(id)scrollView];
    }
    return [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:asset playModel:playModel];
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
       playerSuperViewOfTableHeader:(__unsafe_unretained UIView *)superView
                          tableView:(__unsafe_unretained UITableView *)tableView __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    return [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:asset playModel:[[SJUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperview:superView tableView:tableView]];
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
        collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
            collectionCellIndexPath:(NSIndexPath *)indexPath
                 playerSuperViewTag:(NSInteger)playerSuperViewTag
                      rootTableView:(__unsafe_unretained UITableView *)rootTableView __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    return [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:asset playModel:[[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperviewTag:playerSuperViewTag atIndexPath:indexPath collectionView:collectionView tableView:(id)rootTableView]];
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                          indexPath:(NSIndexPath *__nullable)indexPath
                       superviewTag:(NSInteger)superviewTag
                scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                      scrollViewTag:(NSInteger)scrollViewTag
                     rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    return [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:asset playModel:[[SJUICollectionViewNestedInUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionViewTag:scrollViewTag collectionViewAtIndexPath:scrollViewIndexPath tableView:(id)rootScrollView]];
}
@end
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
