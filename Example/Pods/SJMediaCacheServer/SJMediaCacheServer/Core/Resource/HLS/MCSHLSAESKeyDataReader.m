//
//  MCSHLSAESKeyDataReader.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/23.
//

#import "MCSHLSAESKeyDataReader.h"
#import "MCSHLSResource.h"
#import "MCSFileManager.h"
#import "MCSError.h"
#import "MCSResourceResponse.h"

@interface MCSHLSAESKeyDataReader ()
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong, nullable) id<MCSResourceResponse> response;
@end

@implementation MCSHLSAESKeyDataReader
- (instancetype)initWithResource:(MCSHLSResource *)resource URL:(nonnull NSURL *)URL delegate:(id<MCSResourceDataReaderDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    NSString *path = [resource AESKeyFilePathForAESKeyProxyURL:URL];
    NSRange range = NSMakeRange(0, [MCSFileManager fileSizeAtPath:path]);
    NSRange readRange = range;
    self = [super initWithRange:range path:path readRange:readRange delegate:delegate delegateQueue:queue];
    if ( self ) {
        _URL = URL;
    }
    return self;
}

- (void)prepare {
    if ( ![MCSFileManager fileExistsAtPath:self.path] ) {
        [self onError:[NSError mcs_fileNotExistError:_URL]];
        return;
    }
    
    [self lock];
    _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:@"application/octet-stream" totalLength:[MCSFileManager fileSizeAtPath:self.path]];
    [self unlock];
    [super prepare];
}

- (id<MCSResourceResponse>)response {
    [self lock];
    @try {
        return _response;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@end
