//
//  SJDataDownload.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/5/30.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "MCSResponse.h"

NS_ASSUME_NONNULL_BEGIN
@interface MCSDownload : NSObject<MCSDownloader>
+ (instancetype)shared;

@property (nonatomic) NSTimeInterval timeoutInterval;

@property (nonatomic, copy, nullable) NSMutableURLRequest *_Nullable(^requestHandler)(NSMutableURLRequest *request);

- (nullable id<MCSDownloadTask>)downloadWithRequest:(NSURLRequest *)request priority:(float)priority delegate:(id<MCSDownloadTaskDelegate>)delegate;

@property (nonatomic, copy, nullable) NSData *(^dataEncoder)(NSURLRequest *request, NSUInteger offset, NSData *data);

@property (nonatomic, copy, nullable) void(^errorCallback)(NSURLRequest *request, NSError *error);

- (void)cancelAllDownloadTasks;

@property (nonatomic, readonly) NSInteger taskCount;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end


@interface MCSDownloadResponse : MCSResponse<MCSDownloadResponse>
- (instancetype)initWithHTTPResponse:(NSHTTPURLResponse *)response;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, copy, readonly) NSString *pathExtension;
@property (nonatomic, copy, readonly) NSURL *URL;
@end
NS_ASSUME_NONNULL_END
