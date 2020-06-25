//
//  MCSHLSIndexDataReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSDataReader.h"
#import "MCSHLSParser.h"
@protocol MCSResourceResponse;
@class MCSHLSResource;

NS_ASSUME_NONNULL_BEGIN

@interface MCSHLSIndexDataReader : NSObject<MCSHLSDataReader>
- (instancetype)initWithResource:(MCSHLSResource *)resource URL:(NSURL *)URL delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) MCSHLSParser *parser;
@property (nonatomic, readonly) BOOL isDone;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (void)close;

@end
NS_ASSUME_NONNULL_END
