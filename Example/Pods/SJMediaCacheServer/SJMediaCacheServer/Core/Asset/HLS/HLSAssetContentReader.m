//
//  HLSAssetContentReader.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "HLSAssetContentReader.h"
#import "HLSAsset.h"
#import "MCSLogger.h"
#import "MCSContents.h"
#import "MCSQueue.h"
#import "MCSError.h"
#import "MCSAssetContent.h"
#import "NSFileManager+MCS.h"

@implementation HLSAssetAESKeyContentReader {
    HLSAsset *mAsset;
    NSURLRequest *mRequest;
    float mPriority;
}

- (instancetype)initWithAsset:(HLSAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)priority delegate:(id<MCSAssetContentReaderDelegate>)delegate {
    self = [super initWithAsset:asset delegate:delegate];
    if ( self ) {
        mAsset = asset;
        mRequest = request;
        mPriority = priority;
    }
    return self;
}

- (void)prepareContent {
    
    MCSContentReaderDebugLog(@"%@: <%p>.prepare { request: %@\n };\n", NSStringFromClass(self.class), self, mRequest.mcs_description);

    NSString *filepath = [mAsset AESKeyFilepathWithURL:mRequest.URL];
    if ( [NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
        [self _prepareContentAtPath:filepath];
        return;
    }
    
    MCSContentReaderDebugLog(@"%@: <%p>.download { request: %@\n };\n", NSStringFromClass(self.class), self, mRequest.mcs_description);
    [self _downloadToFile:filepath];
}

- (void)_downloadToFile:(NSString *)filepath {
    [MCSContents request:[mRequest mcs_requestWithHTTPAdditionalHeaders:[mAsset.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSAESKey]] networkTaskPriority:mPriority willPerformHTTPRedirection:nil completed:^(NSData * _Nullable data, NSError * _Nullable downloadError) {
        mcs_queue_sync(^{
            if ( self.status == MCSReaderStatusAborted )
                return;
            
            NSError *writeError = nil;
            // write to file
            if ( downloadError == nil && ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
                [data writeToFile:filepath options:NSDataWritingAtomic error:&writeError];
            }
            
            NSError *error = downloadError ?: writeError;
            if ( error != nil ) {
                [self abortWithError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
                    MCSErrorUserInfoErrorKey : error,
                    MCSErrorUserInfoReasonKey : @"下载失败或写入文件失败!"
                }]];
                return;
            }
            
            [self _prepareContentAtPath:filepath];
        });
    }];
}

- (void)_prepareContentAtPath:(NSString *)filepath {
    UInt64 fileSize = (UInt64)[NSFileManager.defaultManager mcs_fileSizeAtPath:filepath];
    MCSAssetContent *content = [MCSAssetContent.alloc initWithFilepath:filepath startPositionInAsset:0 length:fileSize];
    [content readwriteRetain];
    [self preparationDidFinishWithContentReadwrite:content range:NSMakeRange(0, content.length)];
}
@end


#pragma mark - mark

#import "HLSAssetParser.h"

@interface HLSAssetIndexContentReader ()<HLSAssetParserDelegate> {
    HLSAsset *mAsset;
    NSURLRequest *mRequest;
    float mPriority;
    HLSAssetParser *mTempParser;
}
@end

@implementation HLSAssetIndexContentReader

- (instancetype)initWithAsset:(HLSAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)priority delegate:(id<MCSAssetContentReaderDelegate>)delegate {
    self = [super initWithAsset:asset delegate:delegate];
    if ( self ) {
        mAsset = asset;
        mRequest = request;
        mPriority = priority;
    }
    return self;
}

- (void)prepareContent {
    HLSAssetParser *_Nullable parser = mAsset.parser;
    if ( parser != nil ) {
        [self _prepareContentForParser:parser];
    }
    else {
        mTempParser = [HLSAssetParser.alloc initWithAsset:mAsset request:[mRequest mcs_requestWithHTTPAdditionalHeaders:[mAsset.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSPlaylist]] networkTaskPriority:mPriority delegate:self];
        [mTempParser prepare];
    }
}

#pragma mark - HLSAssetParserDelegate

- (void)parserParseDidFinish:(HLSAssetParser *)parser {
    mcs_queue_sync(^{
        [self _prepareContentForParser:parser];
    });
}

- (void)parser:(HLSAssetParser *)parser anErrorOccurred:(NSError *)error {
    [self abortWithError:error];
}

#pragma mark - mark

- (void)_prepareContentForParser:(HLSAssetParser *)parser {
    switch ( self.status ) {
        case MCSReaderStatusFinished:
        case MCSReaderStatusAborted:
        case MCSReaderStatusReadyToRead:
            break;
        case MCSReaderStatusUnknown:
        case MCSReaderStatusPreparing: {
            if ( mAsset.parser == nil ) {
                mAsset.parser = parser;
            }
            
            NSString *filepath = mAsset.indexFilepath;
            UInt64 fileSize = (UInt64)[NSFileManager.defaultManager mcs_fileSizeAtPath:filepath];
            MCSAssetContent *content = [MCSAssetContent.alloc initWithFilepath:filepath startPositionInAsset:0 length:fileSize];
            [content readwriteRetain];
            [self preparationDidFinishWithContentReadwrite:content range:NSMakeRange(0, fileSize)];
        }
            break;
    }
}
@end


