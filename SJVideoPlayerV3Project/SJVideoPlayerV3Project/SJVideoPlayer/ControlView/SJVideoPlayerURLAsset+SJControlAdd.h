//
//  SJVideoPlayerURLAsset+SJControlAdd.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset (SJControlAdd)

@property (nonatomic, copy, readwrite, nullable) NSString *title;

@property (nonatomic, assign, readwrite) BOOL alwaysShowTitle; // default is `NO`(小屏的时候不显示, 全屏的时候显示标题)

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL;
/**
 player in a view.
 
 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @return instance
 */
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime; // unit is sec.

#pragma mark - Cell
/**
 table or collection cell. player in a tableOrCollection cell.
 
 @param assetURL                        assetURL.
 @param tableOrCollectionView           tableView or collectionView.
 @param indexPath                       cell indexPath.
 @param superviewTag                    player superView tag.
 @return instance
 */
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                   scrollView:(__unsafe_unretained UIScrollView *__nullable)tableOrCollectionView
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag; // video player parent `view tag`

#pragma mark - Table Header View.
/**
 table header view. player in a table header view.
 
 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @param superView                       table header view.
 @param tableView                       table view.
 @return instance
 */
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime
 playerSuperViewOfTableHeader:(__weak UIView *)superView
                    tableView:(UITableView *)tableView;
/**
 table header view. player in a collection view cell, and this collection view in a table header view.
 
 @param assetURL                        assetURL
 @param beginTime                       begin time. unit is sec.
 @param collectionView                  collection view. this view in a table header view.
 @param indexPath                       cell indexPath.
 @param playerSuperViewTag              player superView tag.
 @param rootTableView                   tableView
 @return instance
 */
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime
  collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
      collectionCellIndexPath:(NSIndexPath *)indexPath
           playerSuperViewTag:(NSInteger)playerSuperViewTag
                rootTableView:(UITableView *)rootTableView;

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
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;

@end

NS_ASSUME_NONNULL_END
