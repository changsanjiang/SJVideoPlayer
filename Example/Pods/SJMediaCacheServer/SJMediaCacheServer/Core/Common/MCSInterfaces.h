//
//  MCSInterfaces.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#ifndef MCSInterfaces_h
#define MCSInterfaces_h
#import <Foundation/Foundation.h>
#import "MCSDefines.h"
#import "NSURLRequest+MCS.h"

@protocol MCSProxyTaskDelegate, MCSAssetReaderDelegate;
@protocol MCSResponse, MCSAsset, MCSConfiguration, MCSAssetReader;

NS_ASSUME_NONNULL_BEGIN
@protocol MCSProxyTask <NSObject>
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate;

- (void)prepare;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
@property (nonatomic, strong, readonly, nullable) id<MCSResponse> response;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isDone;
- (void)close;
@end

@protocol MCSProxyTaskDelegate <NSObject>
- (void)taskPrepareDidFinish:(id<MCSProxyTask>)task;
- (void)taskHasAvailableData:(id<MCSProxyTask>)task;
- (void)task:(id<MCSProxyTask>)task anErrorOccurred:(NSError *)error;
@end

#pragma mark -

@protocol MCSResponse <NSObject>
@property (nonatomic, readonly) NSUInteger totalLength;
@property (nonatomic, readonly) NSRange range; // 206请求时length不为0
@end

#pragma mark -

@protocol MCSAsset <NSObject>
@property (nonatomic, readonly) MCSAssetType type;
@property (nonatomic, strong, readonly) id<MCSConfiguration> configuration;

- (id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request;
@end

#pragma mark -
 
@protocol MCSConfiguration <NSObject>

- (nullable NSDictionary<NSString *, NSString *> *)HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type;
- (void)setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)key ofType:(MCSDataType)type;

@end
 
#pragma mark -

@protocol MCSAssetReader <NSObject>
@property (nonatomic, weak, nullable) id<MCSAssetReaderDelegate> delegate;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) id<MCSResponse> response;
@property (nonatomic, readonly) NSUInteger availableLength;
@property (nonatomic, readonly) NSUInteger offset;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (BOOL)seekToOffset:(NSUInteger)offset;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isReadingEndOfData;
@property (nonatomic, readonly) BOOL isClosed;
- (void)close;

@property (nonatomic, copy, nullable) NSData *(^readDataDecoder)(NSURLRequest *request, NSUInteger offset, NSData *data);

@property (nonatomic) float networkTaskPriority;
@end

@protocol MCSAssetReaderDelegate <NSObject>
- (void)reader:(id<MCSAssetReader>)reader prepareDidFinish:(id<MCSResponse>)response;
- (void)reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length;
- (void)reader:(id<MCSAssetReader>)reader anErrorOccurred:(NSError *)error;
@end
NS_ASSUME_NONNULL_END

#endif /* MCSInterfaces_h */
