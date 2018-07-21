//
//  SJVideoPlayerURLAsset.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"

@interface SJVideoPlayerURLAsset ()

@property (nonatomic, strong) SJPlayAsset *playAsset;
@property (nonatomic, strong) SJPlayModel *playModel;

@end

@implementation SJVideoPlayerURLAsset

- (instancetype)initWithPlayAsset:(SJPlayAsset *)playAsset playModel:(__kindof SJPlayModel *)playModel {
    self = [super init];
    if ( !self ) return nil;
    _playAsset = playAsset;
    _playModel = playModel;
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithPlayAsset:[[SJPlayAsset alloc] initWithURL:URL specifyStartTime:specifyStartTime] playModel:playModel];
}

- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    return [self initWithPlayAsset:[[SJPlayAsset alloc] initWithURL:URL specifyStartTime:specifyStartTime] playModel:[SJPlayModel new]];
}

- (instancetype)initWithURL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithURL:URL specifyStartTime:0 playModel:playModel];
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL specifyStartTime:0];
}

- (instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset
                         playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithPlayAsset:[[SJPlayAsset alloc] initWithOtherAsset:otherAsset.playAsset] playModel:playModel?:[SJPlayModel new]];
}

- (BOOL)isM3u8 {
    return [self.playAsset.URL.absoluteString containsString:@".m3u8"];
}

@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation SJVideoPlayerURLAsset (Deprecated)
- (instancetype)initWithAssetURL:(NSURL *)assetURL __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    return [self initWithAssetURL:assetURL beginTime:0];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    self = [super init];
    if ( !self ) return nil;
    self.playAsset = [[SJPlayAsset alloc] initWithURL:assetURL specifyStartTime:beginTime];
    self.playModel = [[SJPlayModel alloc] init];
    return self;
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    return [self initWithAssetURL:assetURL beginTime:0 scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime // unit is sec.
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    self = [super init];
    if ( !self ) return nil;
    self.playAsset = [[SJPlayAsset alloc] initWithURL:assetURL specifyStartTime:beginTime];
    if( [scrollView isKindOfClass:[UITableView class]] ) {
        self.playModel = [[SJUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath tableView:(id)scrollView];
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        self.playModel = [[SJUICollectionViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionView:(id)scrollView];
    }
    return self;
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    return [self initWithAssetURL:assetURL beginTime:0 playerSuperViewOfTableHeader:superView tableView:tableView];
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    self = [super init];
    if ( !self ) return nil;
    self.playAsset = [[SJPlayAsset alloc] initWithURL:assetURL specifyStartTime:beginTime];
    self.playModel = [[SJUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperview:superView tableView:tableView];
    return self;
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
     collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
         collectionCellIndexPath:(NSIndexPath *)indexPath
              playerSuperViewTag:(NSInteger)playerSuperViewTag
                   rootTableView:(UITableView *)rootTableView __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    self = [super init];
    if ( !self ) return nil;
    self.playAsset = [[SJPlayAsset alloc] initWithURL:assetURL specifyStartTime:beginTime];
    self.playModel = [[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperviewTag:playerSuperViewTag atIndexPath:indexPath collectionView:collectionView tableView:rootTableView];
    return self;
}
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime // unit is sec.
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView __deprecated_msg("已弃用, 请使用 `initWithPlayAsset:playModel`;") {
    self = [super init];
    if ( !self ) return nil;
    self.playAsset = [[SJPlayAsset alloc] initWithURL:assetURL specifyStartTime:beginTime];
    self.playModel = [[SJUICollectionViewNestedInUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionViewTag:scrollViewTag collectionViewAtIndexPath:scrollViewIndexPath tableView:(id)rootScrollView];
    return self;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.playAsset = asset.playAsset;
    asset_new.playModel = [[SJPlayModel alloc] init];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                         scrollView:(__unsafe_unretained UIScrollView * __nullable)tableOrCollectionView
                          indexPath:(NSIndexPath * __nullable)indexPath
                       superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.playAsset = asset.playAsset;
    asset_new.playModel = asset.playModel;
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
       playerSuperViewOfTableHeader:(__unsafe_unretained UIView *)superView
                          tableView:(__unsafe_unretained UITableView *)tableView __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.playAsset = asset.playAsset;
    asset_new.playModel = [[SJUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperview:superView tableView:tableView];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
        collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
            collectionCellIndexPath:(NSIndexPath *)indexPath
                 playerSuperViewTag:(NSInteger)playerSuperViewTag
                      rootTableView:(__unsafe_unretained UITableView *)rootTableView __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.playAsset = asset.playAsset;
    asset_new.playModel = [[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperviewTag:playerSuperViewTag atIndexPath:indexPath collectionView:collectionView tableView:(id)rootTableView];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                          indexPath:(NSIndexPath *__nullable)indexPath
                       superviewTag:(NSInteger)superviewTag
                scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                      scrollViewTag:(NSInteger)scrollViewTag
                     rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView __deprecated_msg("已弃用, 请使用 `initWithOtherAsset:playModel`;") {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.playAsset = asset.playAsset;
    asset_new.playModel = [[SJUICollectionViewNestedInUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:superviewTag atIndexPath:indexPath collectionViewTag:scrollViewTag collectionViewAtIndexPath:scrollViewIndexPath tableView:(id)rootScrollView];
    return asset_new;
}
@end
NSString * const kSJVideoPlayerAssetKey = @"asset";
#pragma clang diagnostic pop
