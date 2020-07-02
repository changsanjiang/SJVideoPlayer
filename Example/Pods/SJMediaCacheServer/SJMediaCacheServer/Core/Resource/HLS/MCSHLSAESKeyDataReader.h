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
- (instancetype)initWithResource:(MCSHLSResource *)resource URL:(NSURL *)URL networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

- (void)prepare;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isDone;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (void)close;
@end

NS_ASSUME_NONNULL_END
