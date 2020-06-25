//
//  MCSVODMetaDataReader.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/25.
//

#import <Foundation/Foundation.h>
@protocol MCSVODMetaDataReaderDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MCSVODMetaDataReader : NSObject

- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<MCSVODMetaDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;

@property (nonatomic, weak, readonly, nullable) id<MCSVODMetaDataReaderDelegate> delegate;
@property (nonatomic, copy, readonly, nullable) NSString *contentType;
@property (nonatomic, copy, readonly, nullable) NSString *server;
@property (nonatomic, readonly) NSUInteger totalLength;
@property (nonatomic, copy, readonly, nullable) NSString *pathExtension;

@end

@protocol MCSVODMetaDataReaderDelegate <NSObject>
- (void)metaDataReader:(MCSVODMetaDataReader *)reader didCompleteWithError:(NSError *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
