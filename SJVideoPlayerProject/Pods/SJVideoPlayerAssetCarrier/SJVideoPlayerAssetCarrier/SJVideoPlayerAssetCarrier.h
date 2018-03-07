//
//  SJVideoPlayerAssetCarrier.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//
//  https://github.com/changsanjiang/SJVideoPlayerAssetCarrier
//  Demo: https://github.com/changsanjiang/SJVideoPlayer
//  changsanjiang@gmail.com
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPreviewModel;

@interface SJVideoPlayerAssetCarrier : NSObject

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
                       tableView:(__unsafe_unretained UITableView *)tableView;

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
                   rootTableView:(__unsafe_unretained UITableView *)rootTableView;

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

/**
 table or collection cell. player in a collection cell. and this collectionView in a tableView.
 video player -> collection cell -> collection view -> table cell -> table view.

 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @param indexPath                       collection cell indexPath.
 @param superviewTag                    player superView tag.
 @param scrollViewIndexPath             collection view of indexPath in a tableView.
 @param scrollViewTag                   collection view tag.
 @param scrollView                      collection view.
 @param rootScrollView                  table view.
 @return instance
 */
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;


#pragma mark - screenshot
- (UIImage * __nullable)screenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJVideoPlayerAssetCarrier *asset, SJVideoPreviewModel * __nullable images, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJVideoPlayerAssetCarrier *asset, SJVideoPreviewModel * __nullable images, NSError *__nullable error))block;


#pragma mark - player status
@property (nonatomic, copy, readwrite, nullable) void(^loadedPlayerExeBlock)(SJVideoPlayerAssetCarrier *asset);

@property (nonatomic, copy, readwrite, nullable) void(^playerItemStateChanged)(SJVideoPlayerAssetCarrier *asset, AVPlayerItemStatus status);

@property (nonatomic, copy, readwrite, nullable) void(^playTimeChanged)(SJVideoPlayerAssetCarrier *asset, NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(SJVideoPlayerAssetCarrier *asset);
/// 缓冲进度回调
@property (nonatomic, copy, readwrite, nullable) void(^loadedTimeProgress)(float progress);
/// 缓冲已为空, 开始缓冲
@property (nonatomic, copy, readwrite, nullable) void(^startBuffering)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite, nullable) void(^completeBuffer)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite, nullable) void(^cancelledBuffer)(SJVideoPlayerAssetCarrier *asset);


#pragma mark - scroll view
@property (nonatomic, copy, readwrite, nullable) void(^touchedScrollView)(SJVideoPlayerAssetCarrier *asset, BOOL tracking);

@property (nonatomic, copy, readwrite, nullable) void(^scrollViewDidScroll)(SJVideoPlayerAssetCarrier *asset);

@property (nonatomic, copy, readwrite, nullable) void(^presentationSize)(SJVideoPlayerAssetCarrier *asset, CGSize size);

@property (nonatomic, copy, readwrite, nullable) void(^scrollIn)(SJVideoPlayerAssetCarrier *asset, UIView *superView);

@property (nonatomic, copy, readwrite, nullable) void(^scrollOut)(SJVideoPlayerAssetCarrier *asset);


#pragma mark - preview images
@property (nonatomic, assign, readonly) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) NSArray<SJVideoPreviewModel *> *generatedPreviewImages;
@property (nonatomic, assign, readonly) CGSize maxItemSize;
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJVideoPlayerAssetCarrier *asset, NSArray<SJVideoPreviewModel *> *__nullable images, NSError *__nullable error))block;
- (void)cancelPreviewImagesGeneration;


#pragma mark - seek to time
- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;


#pragma mark - rate
@property (nonatomic, assign) float rate; // default is 1.0
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(SJVideoPlayerAssetCarrier *asset, float rate);


#pragma mark - other
- (NSString *)timeString:(NSInteger)secs;
@property (nonatomic, copy, readwrite, nullable) void(^deallocExeBlock)(SJVideoPlayerAssetCarrier *asset);


#pragma mark - Refresh & Convert

- (void)refreshAVPlayer;

- (void)convertToOriginal; // 还原

/**
 *  player in a view.
 *
 *  video player -> UIView
 **/
- (void)convertToUIView;

/**
 *  table or collection cell. player in a tableOrCollection cell.
 *
 *  video player -> cell -> table || collection view
 *
 **/
- (void)convertToCellWithTableOrCollectionView:(__unsafe_unretained UIScrollView *)tableOrCollectionView
                                        indexPath:(NSIndexPath *)indexPath
                               playerSuperviewTag:(NSInteger)superviewTag;

/**
 *  table header view. player in a table header view.
 *
 *  video player -> table header view -> table view
 *
 **/
- (void)convertToTableHeaderViewWithPlayerSuperView:(__weak UIView *)superView
                                             tableView:(__unsafe_unretained UITableView *)tableView;

/**
 *  table header view. player in a collection view cell, and this collection view in a table header view.
 *
 *  video player -> cell -> collection view -> table header view -> table view
 *
 **/
- (void)convertToTableHeaderViewWithCollectionView:(__weak UICollectionView *)collectionView
                              collectionCellIndexPath:(NSIndexPath *)indexPath
                                   playerSuperViewTag:(NSInteger)playerSuperViewTag
                                        rootTableView:(__unsafe_unretained UITableView *)rootTableView;

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
                        rootTableView:(__unsafe_unretained UITableView *)rootTableView;










#pragma mark - properties
@property (nonatomic, assign, readonly) BOOL converted;
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, assign, readonly) NSTimeInterval beginTime; // unit is sec.
@property (nonatomic, assign, readonly) NSTimeInterval duration;  // unit is sec.
@property (nonatomic, assign, readonly) NSTimeInterval currentTime; // unit is sec.
@property (nonatomic, assign, readonly) float progress; // 0..1
@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) NSInteger superviewTag;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSInteger scrollViewTag; // _scrollView `tag`
@property (nonatomic, strong, readonly, nullable) NSIndexPath *scrollViewIndexPath;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *rootScrollView;
@property (nonatomic, weak, readonly, nullable) UIView *tableHeaderSubView;

@end


#pragma mark - preview model
@interface SJVideoPreviewModel : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time;

@end

NS_ASSUME_NONNULL_END
