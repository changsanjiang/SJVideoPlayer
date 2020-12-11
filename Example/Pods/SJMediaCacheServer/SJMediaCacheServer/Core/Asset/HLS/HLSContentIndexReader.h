//
//  HLSContentIndexReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAssetDefines.h"
#import "HLSParser.h"
@class HLSAsset;

NS_ASSUME_NONNULL_BEGIN

@interface HLSContentIndexReader : NSObject<MCSAssetDataReader>
- (instancetype)initWithAsset:(HLSAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSAssetDataReaderDelegate>)delegate;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) HLSParser *parser; 
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
