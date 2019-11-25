//
//  SJVideoPlayerURLAssetPrefetcher.m
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import "SJVideoPlayerURLAssetPrefetcher.h"
#import "SJAVMediaPlayerLoader.h"
#define __SJPrefetchMaxCount  (3)

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAssetPrefetcher ()
@property (nonatomic, strong, readonly) NSMutableArray<SJVideoPlayerURLAsset *> *m;
@end

@implementation SJVideoPlayerURLAssetPrefetcher
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _maxCount = 3;
    _m = [NSMutableArray array];
    return self;
}
- (SJPrefetchIdentifier)prefetchAsset:(SJVideoPlayerURLAsset *)asset {
    if ( asset ) {
        NSInteger idx = [self _indexOfAsset:asset];
        if ( idx == NSNotFound ) {
            if ( _m.count > _maxCount ) {
                [_m removeObjectAtIndex:0];
            }
            // load asset
            [SJAVMediaPlayerLoader loadPlayerForMedia:asset];
            [_m addObject:asset];
        }
    }
    return (NSInteger)asset;
}
- (SJVideoPlayerURLAsset *_Nullable)assetForURL:(NSURL *)URL {
    if ( URL ) {
        for ( SJVideoPlayerURLAsset *asset in _m ) {
            if ( [asset.mediaURL isEqual:URL] )
                return asset;
        }
    }
    return nil;
}
- (SJVideoPlayerURLAsset *_Nullable)assetForIdentifier:(SJPrefetchIdentifier)identifier {
    for ( SJVideoPlayerURLAsset *asset in _m ) {
        if ( (NSInteger)asset == identifier )
            return asset;
    }
    return nil;
}
- (void)removeAsset:(SJVideoPlayerURLAsset *)asset {
    NSInteger idx = [self _indexOfAsset:asset];
    if ( idx != NSNotFound )
        [_m removeObjectAtIndex:idx];
}
- (NSInteger)_indexOfAsset:(SJVideoPlayerURLAsset *)asset {
    if (  asset ) {
        for ( NSInteger i = 0 ; i < _m.count ; ++ i ) {
            SJVideoPlayerURLAsset *a = _m[i];
            if ( a == asset || [a.mediaURL isEqual:asset.mediaURL] ) {
                return i;
            }
        }
    }
    return NSNotFound;
}
@end
NS_ASSUME_NONNULL_END
