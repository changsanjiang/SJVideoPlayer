//
//  MCSAssetFileRead.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "MCSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSAssetFileRead : NSObject<MCSAssetDataReader>
- (instancetype)initWithAsset:(id<MCSAsset>)asset inRange:(NSRange)range reference:(nullable id<MCSReadwriteReference>)reference path:(NSString *)path readRange:(NSRange)readRange delegate:(id<MCSAssetDataReaderDelegate>)delegate;

- (void)prepare;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSUInteger availableLength;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isDone;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (BOOL)seekToOffset:(NSUInteger)offset;
- (void)close;

@end

NS_ASSUME_NONNULL_END
