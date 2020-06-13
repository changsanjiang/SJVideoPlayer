//
//  MCSHLSReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSDefines.h"
#import "MCSResourceDefines.h"
#import "MCSResourceResponse.h"
@class MCSHLSResource;

NS_ASSUME_NONNULL_BEGIN

@interface MCSHLSReader : NSObject<MCSResourceReader>
- (instancetype)initWithResource:(__weak MCSHLSResource *)resource request:(NSURLRequest *)request;

@property (nonatomic, weak, nullable) id<MCSResourceReaderDelegate> delegate;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
@property (nonatomic, readonly) NSUInteger offset;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isReadingEndOfData;
@property (nonatomic, readonly) BOOL isClosed;
- (void)close;

@property (nonatomic) float networkTaskPriority;
@end

NS_ASSUME_NONNULL_END
