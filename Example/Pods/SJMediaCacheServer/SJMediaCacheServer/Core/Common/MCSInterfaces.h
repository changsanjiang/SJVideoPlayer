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
#import <SJUIKit/SJSQLiteTableModelProtocol.h>
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
@property (nonatomic, copy, readonly) NSString *contentType; // default is "application/octet-stream"
@end

#pragma mark -

@protocol MCSSaveable <SJSQLiteTableModelProtocol>

@end


@protocol MCSReadwriteReference <NSObject>
@property (nonatomic, readonly) NSInteger readwriteCount; // kvo

- (void)readwriteRetain;
- (void)readwriteRelease;
@end

#pragma mark -

@protocol MCSAsset <MCSReadwriteReference, MCSSaveable>
- (instancetype)initWithName:(NSString *)name;
@property (nonatomic, readonly) NSInteger id;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, readonly) MCSAssetType type;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong, readonly) id<MCSConfiguration> configuration;
@property (nonatomic, readonly) BOOL isStored;
- (void)prepare;
@end

#pragma mark -
 
@protocol MCSConfiguration <NSObject>

- (nullable NSDictionary<NSString *, NSString *> *)HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type;
- (void)setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)key ofType:(MCSDataType)type;

@end
 
#pragma mark -

@protocol MCSAssetReader <NSObject>

- (void)prepare;
@property (nonatomic, copy, readonly, nullable) NSData *(^readDataDecoder)(NSURLRequest *request, NSUInteger offset, NSData *data);
@property (nonatomic, weak, readonly, nullable) id<MCSAssetReaderDelegate> delegate;
@property (nonatomic, weak, readonly, nullable) id<MCSAsset> asset;
@property (nonatomic, readonly) float networkTaskPriority;
@property (nonatomic, strong, readonly, nullable) id<MCSResponse> response;
@property (nonatomic, readonly) NSUInteger availableLength;
@property (nonatomic, readonly) NSUInteger offset;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (BOOL)seekToOffset:(NSUInteger)offset;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isReadingEndOfData;
@property (nonatomic, readonly) BOOL isClosed;
- (void)close;
@end

@protocol MCSAssetReaderDelegate <NSObject>
- (void)reader:(id<MCSAssetReader>)reader prepareDidFinish:(id<MCSResponse>)response;
- (void)reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length;
- (void)reader:(id<MCSAssetReader>)reader anErrorOccurred:(NSError *)error;
@end

@protocol MCSAssetContent <MCSReadwriteReference>
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, readonly) long long length;
- (void)didWriteDataWithLength:(NSUInteger)length;
@end


#pragma mark - Download

@protocol MCSDownloadResponse <MCSResponse>
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, copy, readonly) NSString *pathExtension;
@property (nonatomic, copy, readonly) NSURL *URL;
@end

@protocol MCSDownloadTask <NSObject>
- (void)cancel;
@end

@protocol MCSDownloadTaskDelegate <NSObject>
- (void)downloadTask:(id<MCSDownloadTask>)task didReceiveResponse:(id<MCSDownloadResponse>)response;
- (void)downloadTask:(id<MCSDownloadTask>)task didReceiveData:(NSData *)data;
- (void)downloadTask:(id<MCSDownloadTask>)task didCompleteWithError:(NSError *)error;
- (void)downloadTask:(id<MCSDownloadTask>)task willPerformHTTPRedirectionWithNewRequest:(NSURLRequest *)request;
@end

@protocol MCSDownloader <NSObject>
- (nullable id<MCSDownloadTask>)downloadWithRequest:(NSURLRequest *)request priority:(float)priority delegate:(id<MCSDownloadTaskDelegate>)delegate;
- (void)cancelAllDownloadTasks;
@end

NS_ASSUME_NONNULL_END

#endif /* MCSInterfaces_h */
