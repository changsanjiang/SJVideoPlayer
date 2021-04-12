//
//  MCSAssetManager.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "MCSURL.h" 
@class MCSAsset;

typedef NSNumber MCSAssetTypeNumber;
typedef NSNumber MCSAssetIDNumber;

NS_ASSUME_NONNULL_BEGIN
@interface MCSAssetManager : NSObject
+ (instancetype)shared;

- (nullable __kindof id<MCSAsset>)assetWithURL:(NSURL *)URL;

- (nullable __kindof id<MCSAsset>)assetWithName:(NSString *)name type:(MCSAssetType)type;

- (nullable __kindof id<MCSAsset>)assetForAssetId:(NSInteger)assetId type:(MCSAssetType)type;

- (BOOL)isAssetStoredForURL:(NSURL *)URL;

/// Decode the read data.
///
///     This block will be invoked when the reader reads the data, where you can perform some decoding operations on the data.
///
@property (nonatomic, copy, nullable) NSData *(^readDataDecoder)(NSURLRequest *request, NSUInteger offset, NSData *data);

- (nullable id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)proxyRequest networkTaskPriority:(float)networkTaskPriority delegate:(nullable id<MCSAssetReaderDelegate>)delegate;

@property (nonatomic, readonly) UInt64 countOfBytesAllAssets;

@property (nonatomic, readonly) NSInteger countOfAllAssets;

- (UInt64)countOfBytesNotIn:(nullable NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *)assets;

- (void)removeAssetsNotIn:(nullable NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *)assets;
- (void)removeAssetForURL:(NSURL *)URL;
- (void)removeAsset:(id<MCSAsset>)asset;
- (void)removeAssetsInArray:(NSArray<id<MCSAsset>> *)array;

- (void)removeAssetsForLastReadingTime:(NSTimeInterval)timeLimit notIn:(nullable NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *)assets;
- (void)removeAssetsForLastReadingTime:(NSTimeInterval)timeLimit notIn:(nullable NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *)assets countLimit:(NSInteger)maxCount;
@end
NS_ASSUME_NONNULL_END


#import "HLSAsset.h"

NS_ASSUME_NONNULL_BEGIN
@interface HLSAsset (MCSAssetManagerExtended)
@property (nonatomic, readonly, nullable) NSArray<HLSAsset *> *subAssets;
@end
NS_ASSUME_NONNULL_END
