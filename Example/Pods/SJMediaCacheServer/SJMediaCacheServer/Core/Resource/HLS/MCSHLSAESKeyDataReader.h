//
//  MCSHLSAESKeyDataReader.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/23.
//

#import "MCSHLSDataReader.h"
#import "MCSHLSParser.h"
@protocol MCSResourceResponse;
@class MCSHLSResource;

NS_ASSUME_NONNULL_BEGIN

@interface MCSHLSAESKeyDataReader : NSObject<MCSHLSDataReader>
- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
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
