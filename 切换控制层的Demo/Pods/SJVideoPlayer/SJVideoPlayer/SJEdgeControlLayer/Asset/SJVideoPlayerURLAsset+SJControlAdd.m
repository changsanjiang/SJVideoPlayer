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

- (instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithTitle:title alwaysShowTitle:NO URL:URL playModel:playModel];
}

- (instancetype)initWithTitle:(NSString *)title alwaysShowTitle:(BOOL)alwaysShowTitle URL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithTitle:title alwaysShowTitle:alwaysShowTitle URL:URL specifyStartTime:0 playModel:playModel];
}

- (instancetype)initWithTitle:(NSString *)title alwaysShowTitle:(BOOL)alwaysShowTitle URL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel {
    self = [self initWithURL:URL specifyStartTime:specifyStartTime playModel:playModel];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`") {
    return [self initWithTitle:title alwaysShowTitle:alwaysShowTitle assetURL:assetURL beginTime:0];
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`") {
    self = [self initWithAssetURL:assetURL beginTime:beginTime];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                   scrollView:(__unsafe_unretained UIScrollView *__nullable)tableOrCollectionView
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`") {
    self = [self initWithAssetURL:assetURL beginTime:beginTime scrollView:tableOrCollectionView indexPath:indexPath superviewTag:superviewTag];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime
 playerSuperViewOfTableHeader:(__weak UIView *)superView
                    tableView:(UITableView *)tableView __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`") {
    self = [self initWithAssetURL:assetURL beginTime:beginTime playerSuperViewOfTableHeader:superView tableView:tableView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime
  collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
      collectionCellIndexPath:(NSIndexPath *)indexPath
           playerSuperViewTag:(NSInteger)playerSuperViewTag
                rootTableView:(UITableView *)rootTableView __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`") {
    self = [self initWithAssetURL:assetURL beginTime:beginTime collectionViewOfTableHeader:collectionView collectionCellIndexPath:indexPath playerSuperViewTag:playerSuperViewTag rootTableView:rootTableView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView __deprecated_msg("已弃用, 请使用`initWithTitle:URL:playModel`") {
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
