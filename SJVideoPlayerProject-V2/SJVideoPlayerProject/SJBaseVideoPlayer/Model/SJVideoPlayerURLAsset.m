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

/// unit is sec.
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL beginTime:beginTime];
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
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [super init];
    if ( !self ) return nil;
    self.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:assetURL indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag rootScrollView:rootScrollView];
    return self;
}

@end

NSString * const kSJVideoPlayerAssetKey = @"asset";
