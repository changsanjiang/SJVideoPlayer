//
//  MCSDefines.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#ifndef MCSDefines_h
#define MCSDefines_h
#import <Foundation/Foundation.h>
#import "NSURLRequest+MCS.h"
@protocol MCSSessionTaskDelegate, MCSResourceReaderDelegate;
@protocol MCSResource, MCSResourceResponse, MCSResourceReader;

typedef NS_ENUM(NSUInteger, MCSResourceType) {
    MCSResourceTypeVOD,
    MCSResourceTypeHLS
};

NS_ASSUME_NONNULL_BEGIN
@protocol MCSSessionTask <NSObject>
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<MCSSessionTaskDelegate>)delegate;

- (void)prepare;
@property (nonatomic, copy, readonly, nullable) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSUInteger contentLength;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isDone;
- (void)close;
@end


@protocol MCSSessionTaskDelegate <NSObject>
- (void)taskPrepareDidFinish:(id<MCSSessionTask>)task;
- (void)taskHasAvailableData:(id<MCSSessionTask>)task;
- (void)task:(id<MCSSessionTask>)task anErrorOccurred:(NSError *)error;
@end
 
#pragma mark -
 
@protocol MCSResource <NSObject>
@property (nonatomic, readonly) MCSResourceType type;

- (id<MCSResourceReader>)readerWithRequest:(NSURLRequest *)request;
@end

#pragma mark -

@protocol MCSResourceResponse <NSObject>
@property (nonatomic, copy, readonly, nullable) NSDictionary *responseHeaders;
- (nullable NSString *)contentType;
- (nullable NSString *)server;
- (NSUInteger)totalLength;
- (NSRange)contentRange;
@end

#pragma mark -

@protocol MCSResourceReader <NSObject>
@property (nonatomic, weak, nullable) id<MCSResourceReaderDelegate> delegate;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) id<MCSResourceResponse> response;
@property (nonatomic, readonly) NSUInteger offset;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isReadingEndOfData;
@property (nonatomic, readonly) BOOL isClosed;
- (void)close;

@property (nonatomic, copy, nullable) NSData *(^readDataDecoder)(NSURLRequest *request, NSUInteger offset, NSData *data);

@property (nonatomic) float networkTaskPriority;
@end

@protocol MCSResourceReaderDelegate <NSObject>
- (void)readerPrepareDidFinish:(id<MCSResourceReader>)reader;
- (void)readerHasAvailableData:(id<MCSResourceReader>)reader;
- (void)reader:(id<MCSResourceReader>)reader anErrorOccurred:(NSError *)error;
@end
NS_ASSUME_NONNULL_END

#endif /* MCSDefines_h */
