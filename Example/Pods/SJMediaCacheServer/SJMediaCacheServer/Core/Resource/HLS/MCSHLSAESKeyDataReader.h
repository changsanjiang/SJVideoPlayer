//
//  MCSHLSAESKeyDataReader.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/23.
//

#import "MCSHLSDataReader.h"
#import "MCSResourceFileDataReader.h"
@class MCSHLSResource;

NS_ASSUME_NONNULL_BEGIN

@interface MCSHLSAESKeyDataReader : MCSResourceFileDataReader<MCSHLSDataReader>
- (instancetype)initWithResource:(MCSHLSResource *)resource URL:(NSURL *)URL delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
@end

NS_ASSUME_NONNULL_END
