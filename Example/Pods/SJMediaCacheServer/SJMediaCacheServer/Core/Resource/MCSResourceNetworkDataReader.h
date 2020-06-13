//
//  MCSResourceNetworkDataReader.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceDefines.h"
#import "MCSResourceResponse.h"
@class MCSResourcePartialContent;

NS_ASSUME_NONNULL_BEGIN

@interface MCSResourceNetworkDataReader : NSObject<MCSResourceDataReader>
- (instancetype)initWithURL:(NSURL *)URL requestHeaders:(NSDictionary *)headers range:(NSRange)range networkTaskPriority:(float)networkTaskPriority;

@property (nonatomic, readonly) NSRange range;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) NSHTTPURLResponse *response;
@property (nonatomic, readonly) BOOL isDone;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (void)close;
@end

@protocol MCSResourceNetworkDataReaderDelegate <MCSResourceDataReaderDelegate>
- (MCSResourcePartialContent *)newPartialContentForReader:(MCSResourceNetworkDataReader *)reader;
- (NSString *)writePathOfPartialContent:(MCSResourcePartialContent *)content;
@end

NS_ASSUME_NONNULL_END
