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

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL {
    self = [self initWithAssetURL:assetURL];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

/// unit is sec.
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

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    beginTime:(NSTimeInterval)beginTime // unit is sec.
                   scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag {
    self = [self initWithAssetURL:assetURL beginTime:beginTime scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
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
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [self initWithAssetURL:assetURL beginTime:beginTime indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag rootScrollView:rootScrollView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                   scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                    indexPath:(NSIndexPath * __nullable)indexPath
                 superviewTag:(NSInteger)superviewTag {
    self = [self initWithAssetURL:assetURL scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
              alwaysShowTitle:(BOOL)alwaysShowTitle
                     assetURL:(NSURL *)assetURL
                    indexPath:(NSIndexPath *__nullable)indexPath
                 superviewTag:(NSInteger)superviewTag
          scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                scrollViewTag:(NSInteger)scrollViewTag
               rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [self initWithAssetURL:assetURL indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag rootScrollView:rootScrollView];
    if ( !self ) return nil;
    self.title = title;
    self.alwaysShowTitle = alwaysShowTitle;
    return self;
}
@end
