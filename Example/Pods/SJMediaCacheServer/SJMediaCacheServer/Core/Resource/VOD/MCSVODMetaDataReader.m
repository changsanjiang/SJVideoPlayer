//
//  MCSVODMetaDataReader.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/25.
//

#import "MCSVODMetaDataReader.h"
#import "MCSDownload.h"
#import "NSURLRequest+MCS.h"
#import "MCSUtils.h"

@interface MCSVODMetaDataReader ()<MCSDownloadTaskDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@end

@implementation MCSVODMetaDataReader
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<MCSVODMetaDataReaderDelegate>)delegate delegateQueue:(nonnull dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _request = request;
        _delegate = delegate;
        _delegateQueue = queue;
        [self _prepare];
    }
    return self;
}

- (void)_prepare {
    _task = [MCSDownload.shared downloadWithRequest:[_request mcs_requestWithRange:NSMakeRange(0, 2)] priority:1 delegate:self];
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    _contentType = MCSGetResponseContentType(response);
    _server = MCSGetResponseServer(response);
    _totalLength = MCSGetResponseContentRange(response).totalLength;
    _pathExtension = response.suggestedFilename.pathExtension;
    [task cancel];
    
    [_delegate metaDataReader:self didCompleteWithError:nil];
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ( error && error.code != NSURLErrorCancelled ) {
        dispatch_async(_delegateQueue, ^{
            [self.delegate metaDataReader:self didCompleteWithError:error];
        });
    }
}
@end
