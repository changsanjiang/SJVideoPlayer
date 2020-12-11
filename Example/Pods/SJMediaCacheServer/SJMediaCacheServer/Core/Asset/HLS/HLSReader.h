//
//  HLSReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "MCSAssetDefines.h"
@class HLSAsset;

NS_ASSUME_NONNULL_BEGIN

@interface HLSReader : NSObject<MCSAssetReader>
- (instancetype)initWithAsset:(__weak HLSAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority readDataDecoder:(NSData *(^_Nullable)(NSURLRequest *request, NSUInteger offset, NSData *data))readDataDecoder delegate:(id<MCSAssetReaderDelegate>)delegate;

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

NS_ASSUME_NONNULL_END
