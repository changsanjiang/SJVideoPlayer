//
//  MCSHLSTSDataReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSDataReader.h"
#import "MCSHLSParser.h"
@class MCSHLSResource;

NS_ASSUME_NONNULL_BEGIN

@interface MCSHLSTSDataReader : NSObject<MCSHLSDataReader>

- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority;

- (void)prepare;
@property (nonatomic, readonly) BOOL isDone;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (void)close;

@end

NS_ASSUME_NONNULL_END
