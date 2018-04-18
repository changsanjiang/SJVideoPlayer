//
//  SJVideoPlayerURLAsset.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface SJVideoPlayerURLAsset ()

@property (nonatomic, strong, readwrite) SJVideoPlayerAssetCarrier *asset;

@end

@implementation SJVideoPlayerURLAsset

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    return [self initWithAssetURL:assetURL beginTime:0];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL beginTime:beginTime];
    return self;
}

#pragma mark - Cell

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
    return self;
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime // unit is sec.
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL beginTime:beginTime scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
    return self;
}

#pragma mark - Table Header View.

- (instancetype)initWithAssetURL:(NSURL *)assetURL
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView {
    return [self initWithAssetURL:assetURL beginTime:0 playerSuperViewOfTableHeader:superView tableView:tableView];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL beginTime:beginTime playerSuperViewOfTableHeader:superView tableView:tableView];
    return self;
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
     collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
         collectionCellIndexPath:(NSIndexPath *)indexPath
              playerSuperViewTag:(NSInteger)playerSuperViewTag
                   rootTableView:(UITableView *)rootTableView {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL beginTime:beginTime collectionViewOfTableHeader:collectionView collectionCellIndexPath:indexPath playerSuperViewTag:playerSuperViewTag rootTableView:rootTableView];
    return self;
}

#pragma mark - Nested
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime // unit is sec.
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL beginTime:beginTime indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag rootScrollView:rootScrollView];
    return self;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.asset = [[SJVideoPlayerAssetCarrier alloc] initWithOtherAsset:[asset valueForKey:kSJVideoPlayerAssetKey]];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                         scrollView:(__unsafe_unretained UIScrollView * __nullable)tableOrCollectionView
                          indexPath:(NSIndexPath * __nullable)indexPath
                       superviewTag:(NSInteger)superviewTag {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.asset = [[SJVideoPlayerAssetCarrier alloc] initWithOtherAsset:[asset valueForKey:kSJVideoPlayerAssetKey] scrollView:tableOrCollectionView indexPath:indexPath superviewTag:superviewTag];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
       playerSuperViewOfTableHeader:(__unsafe_unretained UIView *)superView
                          tableView:(__unsafe_unretained UITableView *)tableView {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.asset = [[SJVideoPlayerAssetCarrier alloc] initWithOtherAsset:[asset valueForKey:kSJVideoPlayerAssetKey] playerSuperViewOfTableHeader:superView tableView:tableView];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
        collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
            collectionCellIndexPath:(NSIndexPath *)indexPath
                 playerSuperViewTag:(NSInteger)playerSuperViewTag
                      rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.asset = [[SJVideoPlayerAssetCarrier alloc] initWithOtherAsset:[asset valueForKey:kSJVideoPlayerAssetKey] collectionViewOfTableHeader:collectionView collectionCellIndexPath:indexPath playerSuperViewTag:playerSuperViewTag rootTableView:rootTableView];
    return asset_new;
}
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                          indexPath:(NSIndexPath *__nullable)indexPath
                       superviewTag:(NSInteger)superviewTag
                scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                      scrollViewTag:(NSInteger)scrollViewTag
                     rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    SJVideoPlayerURLAsset *asset_new = [SJVideoPlayerURLAsset new];
    asset_new.asset = [[SJVideoPlayerAssetCarrier alloc] initWithOtherAsset:[asset valueForKey:kSJVideoPlayerAssetKey] indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag rootScrollView:rootScrollView];
    return asset_new;
}

- (BOOL)isM3u8 {
    return [self.asset.assetURL.absoluteString containsString:@".m3u8"];
}

- (id<SJVideoPlayerAssetCarrier>)carrier {
    return (id)self.asset;
}

#pragma mark -
- (BOOL)converted {
    return self.asset.converted;
}

- (void)convertToOriginal {
    [self.asset convertToOriginal];
}

- (SJViewHierarchyStack)viewHierarchyStack {
    return self.asset.viewHierarchyStack;
}

- (void)convertToUIView {
    [self.asset convertToUIView];
}
- (void)convertToCellWithTableOrCollectionView:(__unsafe_unretained UIScrollView *)tableOrCollectionView
                                     indexPath:(NSIndexPath *)indexPath
                            playerSuperviewTag:(NSInteger)superviewTag {
    [self.asset convertToCellWithTableOrCollectionView:tableOrCollectionView indexPath:indexPath playerSuperviewTag:superviewTag];
}
- (void)convertToTableHeaderViewWithPlayerSuperView:(__weak UIView *)superView
                                          tableView:(__unsafe_unretained UITableView *)tableView {
    [self.asset convertToTableHeaderViewWithPlayerSuperView:superView tableView:tableView];
}
- (void)convertToTableHeaderViewWithCollectionView:(__weak UICollectionView *)collectionView
                           collectionCellIndexPath:(NSIndexPath *)indexPath
                                playerSuperViewTag:(NSInteger)playerSuperViewTag
                                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self.asset convertToTableHeaderViewWithCollectionView:collectionView collectionCellIndexPath:indexPath playerSuperViewTag:playerSuperViewTag rootTableView:rootTableView];
}
- (void)convertToCellWithIndexPath:(NSIndexPath *)indexPath
                      superviewTag:(NSInteger)superviewTag
           collectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
                 collectionViewTag:(NSInteger)collectionViewTag
                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self.asset convertToCellWithIndexPath:indexPath superviewTag:superviewTag collectionViewIndexPath:collectionViewIndexPath collectionViewTag:collectionViewTag rootTableView:rootTableView];
}
@end

NSString * const kSJVideoPlayerAssetKey = @"asset";
#pragma clang diagnostic pop
