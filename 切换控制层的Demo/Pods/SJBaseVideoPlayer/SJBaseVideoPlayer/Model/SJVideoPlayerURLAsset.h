//
//  SJVideoPlayerURLAsset.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerAssetCarrier <NSObject>
@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPath;
@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, readonly) BOOL isOtherAsset;
@end

@interface SJVideoPlayerURLAsset : NSObject

@property (nonatomic, assign, readonly) BOOL isM3u8;

@property (nonatomic, strong, readonly) id<SJVideoPlayerAssetCarrier> carrier;

#pragma mark -

- (instancetype)initWithAssetURL:(NSURL *)assetURL;

/**
 player in a view.
 video player -> UIView

 @param assetURL                        assetURL
 @param beginTime                       begin time. unit is sec.
 @return instance
 */
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime;

#pragma mark - Cell

/**
 table or collection cell. player in a tableOrCollection cell.
 video player -> cell -> table || collection view

 @param assetURL                        assetURL.
 @param tableOrCollectionView           tableView or collectionView.
 @param indexPath                       cell indexPath.
 @param superviewTag                    player superView tag.
 @return instance
 */
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)tableOrCollectionView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag;

/**
 table or collection cell. player in a tableOrCollection cell.
 video player -> cell -> table || collection view

 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @param tableOrCollectionView           tableView or collectionView.
 @param indexPath                       cell indexPath.
 @param superviewTag                    player superView tag.
 @return instance
 */
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)tableOrCollectionView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag;

#pragma mark - Table Header View.

/**
 table header view. player in a table header view.
 video player -> table header view -> table view

 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @param superView                       table header view.
 @param tableView                       table view.
 @return instance
 */
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView;

/**
 table header view. player in a collection view cell, and this collection view in a table header view.
 video player -> cell -> collection view -> table header view -> table view
 
 @param assetURL                        assetURL
 @param beginTime                       begin time. unit is sec.
 @param collectionView                  collection view. this view in a table header view.
 @param indexPath                       cell indexPath.
 @param playerSuperViewTag              player superView tag.
 @param rootTableView                   tableView
 @return instance
 */
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
     collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
         collectionCellIndexPath:(NSIndexPath *)indexPath
              playerSuperViewTag:(NSInteger)playerSuperViewTag
                   rootTableView:(UITableView *)rootTableView;

#pragma mark - Nested

/**
 table or collection cell. player in a collection cell. and this collectionView in a tableView.
 video player -> collection cell -> collection view -> table cell -> table view.
 
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
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;




+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset;
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                         scrollView:(__unsafe_unretained UIScrollView * __nullable)tableOrCollectionView
                          indexPath:(NSIndexPath * __nullable)indexPath
                       superviewTag:(NSInteger)superviewTag;
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
       playerSuperViewOfTableHeader:(__unsafe_unretained UIView *)superView
                          tableView:(__unsafe_unretained UITableView *)tableView;
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
        collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
            collectionCellIndexPath:(NSIndexPath *)indexPath
                 playerSuperViewTag:(NSInteger)playerSuperViewTag
                      rootTableView:(__unsafe_unretained UITableView *)rootTableView;
+ (instancetype)assetWithOtherAsset:(SJVideoPlayerURLAsset *)asset
                          indexPath:(NSIndexPath *__nullable)indexPath
                       superviewTag:(NSInteger)superviewTag
                scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                      scrollViewTag:(NSInteger)scrollViewTag
                     rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;


@end

extern NSString * const kSJVideoPlayerAssetKey;

NS_ASSUME_NONNULL_END
