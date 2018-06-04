//
//  SJVideoPlayerURLAsset+SJControlAdd.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import <objc/message.h>

@implementation SJVideoPlayerURLAsset (SJControlAdd)

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL {
    return [self initWithTitle:title alwaysShowTitle:alwaysShowTitle assetURL:assetURL beginTime:0];
}
/**
 player in a view.
 
 @param assetURL                        assetURL.
 @param beginTime                       begin time. unit is sec.
 @return instance
 */
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime {
    self = [self initWithAssetURL:assetURL beginTime:beginTime];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

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
                 superviewTag:(NSInteger)superviewTag {
    self = [self initWithAssetURL:assetURL beginTime:beginTime scrollView:tableOrCollectionView indexPath:indexPath superviewTag:superviewTag];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

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
                    tableView:(UITableView *)tableView {
    self = [self initWithAssetURL:assetURL beginTime:beginTime playerSuperViewOfTableHeader:superView tableView:tableView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

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
                rootTableView:(UITableView *)rootTableView {
    self = [self initWithAssetURL:assetURL beginTime:beginTime collectionViewOfTableHeader:collectionView collectionCellIndexPath:indexPath playerSuperViewTag:playerSuperViewTag rootTableView:rootTableView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
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
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView; {
    self = [self initWithAssetURL:assetURL beginTime:beginTime indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag rootScrollView:rootScrollView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAlwaysShowTitle:(BOOL)alwaysShowTitle {
    objc_setAssociatedObject(self, @selector(alwaysShowTitle), @(alwaysShowTitle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)alwaysShowTitle {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
