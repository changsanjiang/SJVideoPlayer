//
//  SJVideoPlayerURLAsset+SJControlAdd.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerURLAsset.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerURLAsset.h>
#else
#import "SJVideoPlayerURLAsset.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset (SJControlAdd)

- (instancetype)initWithTitle:(NSString *)title
                          URL:(NSURL *)URL
                    playModel:(__kindof SJPlayModel *)playModel;

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                          URL:(NSURL *)URL
                    playModel:(__kindof SJPlayModel *)playModel;

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                          URL:(NSURL *)URL
             specifyStartTime:(NSTimeInterval)specifyStartTime
                    playModel:(__kindof SJPlayModel *)playModel;

@property (nonatomic, copy, nullable) NSString *title;

@property (nonatomic) BOOL alwaysShowTitle; // default is `YES`






#pragma mark - Deprecated

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`");

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`"); // unit is sec.

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                   scrollView:(__unsafe_unretained UIScrollView *__nullable)tableOrCollectionView
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`"); // video player parent `view tag`

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime
 playerSuperViewOfTableHeader:(__weak UIView *)superView
                    tableView:(UITableView *)tableView __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`");

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime
  collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
      collectionCellIndexPath:(NSIndexPath *)indexPath
           playerSuperViewTag:(NSInteger)playerSuperViewTag
                rootTableView:(UITableView *)rootTableView __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`");

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`");

@end

NS_ASSUME_NONNULL_END
