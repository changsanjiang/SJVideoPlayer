//
//  MCSAssetContentReader.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "MCSInterfaces.h"
#import "MCSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MCSAssetContentReader : NSObject<MCSAssetContentReader, MCSAssetContentReaderSubclass>
- (instancetype)initWithAsset:(id<MCSAsset>)asset delegate:(id<MCSAssetContentReaderDelegate>)delegate;
- (void)prepare;
@property (nonatomic, strong, readonly, nullable) __kindof id<MCSAssetContent> content;
@property (nonatomic, readonly) NSRange range; // range in asset
@property (nonatomic, readonly) UInt64 availableLength;
@property (nonatomic, readonly) UInt64 offset;
@property (nonatomic, readonly) MCSReaderStatus status;
- (nullable NSData *)readDataOfLength:(UInt64)length;
- (BOOL)seekToOffset:(UInt64)offset;
- (void)abortWithError:(nullable NSError *)error;
@end


@interface MCSAssetFileContentReader : MCSAssetContentReader

- (instancetype)initWithAsset:(id<MCSAsset>)asset fileContent:(id<MCSAssetContent>)content rangeInAsset:(NSRange)range delegate:(id<MCSAssetContentReaderDelegate>)delegate;

@end


@interface MCSAssetHTTPContentReader : MCSAssetContentReader

- (instancetype)initWithAsset:(id<MCSAsset>)asset request:(NSURLRequest *)request networkTaskPriority:(float)priority dataType:(MCSDataType)dataType delegate:(id<MCSAssetContentReaderDelegate>)delegate;

- (instancetype)initWithAsset:(id<MCSAsset>)asset request:(NSURLRequest *)request rangeInAsset:(NSRange)range contentReadwrite:(nullable id<MCSAssetContent>)content /* 如果content不存在将会通过asset进行创建 */ networkTaskPriority:(float)priority dataType:(MCSDataType)dataType delegate:(id<MCSAssetContentReaderDelegate>)delegate;
@end
NS_ASSUME_NONNULL_END
