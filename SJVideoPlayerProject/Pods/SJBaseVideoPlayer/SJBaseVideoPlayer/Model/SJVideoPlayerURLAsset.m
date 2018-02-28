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
@end

NSString * const kSJVideoPlayerAssetKey = @"asset";
