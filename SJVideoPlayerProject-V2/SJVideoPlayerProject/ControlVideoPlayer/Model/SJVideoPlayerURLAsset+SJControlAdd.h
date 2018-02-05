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

/// unit is sec.
- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime; // unit is sec.

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                   scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag; // video player parent `view tag`

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                   scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                    indexPath:(NSIndexPath * __nullable)indexPath
                 superviewTag:(NSInteger)superviewTag;

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;

@end

NS_ASSUME_NONNULL_END
