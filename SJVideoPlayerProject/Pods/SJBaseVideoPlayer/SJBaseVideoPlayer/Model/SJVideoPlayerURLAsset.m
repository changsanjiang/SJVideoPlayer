//
//  SJVideoPlayerURLAsset.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>

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

/**
 table or collection cell. player in a collection cell. and this collectionView in a tableView.
 
 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @param indexPath                       collection cell indexPath.
 @param superviewTag                    player superView tag.
 @param scrollViewIndexPath             collection view of indexPath in a tableView.
 @param scrollViewTag                   collection view tag.
 @param rootScrollView                  table view.
 @return instance
 */
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


- (BOOL)isM3u8 {
    return [self.asset.assetURL.absoluteString containsString:@".m3u8"];
}

- (BOOL)converted {
    return self.asset.converted;
}

- (void)convertToOriginal {
    [self.asset convertToOriginal];
}

/**
 *  player in a view.
 *
 *  video player -> UIView
 **/
- (void)convertToUIView {
    [self.asset convertToUIView];
}

/**
 *  table or collection cell. player in a tableOrCollection cell.
 *
 *  video player -> cell -> table || collection view
 *
 **/
- (void)convertToCellWithTableOrCollectionView:(__unsafe_unretained UIScrollView *)tableOrCollectionView
                                     indexPath:(NSIndexPath *)indexPath
                            playerSuperviewTag:(NSInteger)superviewTag {
    [self.asset convertToCellWithTableOrCollectionView:tableOrCollectionView indexPath:indexPath playerSuperviewTag:superviewTag];
}

/**
 *  table header view. player in a table header view.
 *
 *  video player -> table header view -> table view
 *
 **/
- (void)convertToTableHeaderViewWithPlayerSuperView:(__weak UIView *)superView
                                          tableView:(__unsafe_unretained UITableView *)tableView {
    [self.asset convertToTableHeaderViewWithPlayerSuperView:superView tableView:tableView];
}

/**
 *  table header view. player in a collection view cell, and this collection view in a table header view.
 *
 *  video player -> cell -> collection view -> table header view -> table view
 *
 **/
- (void)convertToTableHeaderViewWithCollectionView:(__weak UICollectionView *)collectionView
                           collectionCellIndexPath:(NSIndexPath *)indexPath
                                playerSuperViewTag:(NSInteger)playerSuperViewTag
                                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self.asset convertToTableHeaderViewWithCollectionView:collectionView collectionCellIndexPath:indexPath playerSuperViewTag:playerSuperViewTag rootTableView:rootTableView];
}

/**
 *  collection cell. player in a collection cell. and this collectionView in a tableView.
 *
 *  video player -> collection cell -> collection view -> table cell -> table view.
 *
 **/
- (void)convertToCellWithIndexPath:(NSIndexPath *)indexPath
                      superviewTag:(NSInteger)superviewTag
           collectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
                 collectionViewTag:(NSInteger)collectionViewTag
                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self.asset convertToCellWithIndexPath:indexPath superviewTag:superviewTag collectionViewIndexPath:collectionViewIndexPath collectionViewTag:collectionViewTag rootTableView:rootTableView];
}
@end

NSString * const kSJVideoPlayerAssetKey = @"asset";
