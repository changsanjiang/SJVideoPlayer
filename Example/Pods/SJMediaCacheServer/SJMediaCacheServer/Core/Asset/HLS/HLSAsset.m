//
//  HLSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSAsset.h"
#import "MCSConfiguration.h"
#import "MCSURL.h"
#import "MCSUtils.h"
#import "MCSConsts.h"
#import "HLSAssetContentProvider.h"
#import "HLSAssetReader.h"
#import "MCSRootDirectory.h"
#import "MCSQueue.h"

@interface HLSAsset () {
    HLSAssetContentProvider *mProvider;
    NSMutableArray<id<HLSAssetTsContent>> *mTsContents;
    BOOL mIsPrepared;
}

@property (nonatomic) NSInteger id; // saveable
@property (nonatomic, copy) NSString *name; // saveable
@property (nonatomic, copy, nullable) NSString *TsContentType; // saveable
@property (nonatomic, weak, nullable) HLSAsset *root;
@end

@implementation HLSAsset
@synthesize id = _id;
@synthesize configuration = _configuration;
@synthesize parser = _parser;
@synthesize isStored = _isStored;

+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"readwriteCount", @"isStored", @"configuration", @"contents", @"parser", @"root"];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if ( self ) {
        _name = name.copy;
    }
    return self;
}

- (void)prepare {
    mcs_queue_sync(^{
        NSParameterAssert(self.name != nil);
        if ( mIsPrepared )
            return;
        mIsPrepared = YES;
        
        NSString *directory = [MCSRootDirectory assetPathForFilename:self.name];
        _configuration = MCSConfiguration.alloc.init;
        mProvider = [HLSAssetContentProvider.alloc initWithDirectory:directory];
        _parser = [HLSAssetParser parserInAsset:self];
        mTsContents = [(mProvider.TsContents ?: @[]) mutableCopy];
        [self _mergeContents];
    });
}

- (NSString *)path {
    return [MCSRootDirectory assetPathForFilename:_name];
}

#pragma mark - mark

- (void)setParser:(nullable HLSAssetParser *)parser {
    mcs_queue_sync(^{
        _parser = parser;
    });
}

- (nullable HLSAssetParser *)parser {
    __block HLSAssetParser *parser = nil;
    mcs_queue_sync(^{
        parser = _parser;
    });
    return parser;
}

- (MCSAssetType)type {
    return MCSAssetTypeHLS;
}

- (nullable NSArray<id<HLSAssetTsContent>> *)TsContents {
    __block NSArray<id<HLSAssetTsContent>> *contents;
    mcs_queue_sync(^{
        contents = mTsContents;
    });
    return contents;
}

- (BOOL)isStored {
    __block BOOL isStored = NO;
    mcs_queue_sync(^{
        isStored = _isStored;
    });
    return isStored;
}

- (NSString *)indexFilepath {
    return [mProvider indexFilepath];
}

- (NSString *)indexFileRelativePath {
    return [mProvider indexFileRelativePath];
}

- (NSString *)AESKeyFilepathWithURL:(NSURL *)URL {
    return [mProvider AESKeyFilepathWithName:[MCSURL.shared nameWithUrl:URL.absoluteString suffix:HLS_SUFFIX_AES_KEY]];
}

- (nullable NSString *)TsContentType {
    __block NSString *TsContentType = nil;
    mcs_queue_sync(^{
        TsContentType = _TsContentType;
    });
    return TsContentType;
}

- (NSUInteger)tsCount {
    return self.parser.tsCount;
}

@synthesize root = _root;
- (void)setRoot:(nullable HLSAsset *)root {
    mcs_queue_sync(^{
        _root = root;
    });
}

- (nullable HLSAsset *)root {
    __block HLSAsset *root = nil;
    mcs_queue_sync(^{
        root = _root;
    });
    return root;
}

- (nullable id<HLSAssetTsContent>)createTsContentWithResponse:(id<MCSDownloadResponse>)response {
    NSString *TsContentType = response.contentType;
    __block BOOL isUpdated = NO;
    __block id<HLSAssetTsContent>content = nil;
    mcs_queue_sync(^{
        if ( ![TsContentType isEqualToString:_TsContentType] ) {
            _TsContentType = TsContentType;
            isUpdated = YES;
        }
        
        NSString *name = [MCSURL.shared nameWithUrl:response.URL.absoluteString suffix:HLS_SUFFIX_TS];
        
        if ( response.statusCode == MCS_RESPONSE_CODE_PARTIAL_CONTENT ) {
            content = [mProvider createTsContentWithName:name totalLength:response.totalLength rangeInAsset:response.range];
        }
        else {
            content = [mProvider createTsContentWithName:name totalLength:response.totalLength];
        }
        
        [mTsContents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}
 
- (nullable id<HLSAssetTsContent>)TsContentForRequest:(NSURLRequest *)request {
    NSString *name = [MCSURL.shared nameWithUrl:request.URL.absoluteString suffix:HLS_SUFFIX_TS];
    __block id<HLSAssetTsContent>ts = nil;
    mcs_queue_sync(^{
        // range
        NSRange r = NSMakeRange(0, 0);
        BOOL isRangeRequest = MCSRequestIsRangeRequest(request);
        MCSRequestContentRange range = MCSRequestContentRangeUndefined;
        if ( isRangeRequest ) {
            range = MCSRequestGetContentRange(request.allHTTPHeaderFields);
            r = MCSRequestRange(range);
        }
        
        for ( id<HLSAssetTsContent>content in mTsContents ) {
            if ( ![content.name isEqualToString:name] ) continue;
            if ( isRangeRequest && !NSEqualRanges(r, content.rangeInAsset) ) continue;
            
            if ( content.length == content.rangeInAsset.length ) {
                ts = content;
                break;
            }
        }
    });
    return ts;
}

/// 将返回如下两种content, 如果未满足条件, 则返回nil
///
///     - 如果ts已缓存完毕, 则返回完整的content
///
///     - 如果ts被缓存了一部分(可能存在多个), 则将返回长度最长的并且readwrite为0的content
///
/// 该操作将会对 content 进行一次 readwriteRetain, 请在不需要时, 调用一次 readwriteRelease.
///
- (nullable id<HLSAssetTsContent>)TsContentReadwriteForRequest:(NSURLRequest *)request {
    NSString *name = [MCSURL.shared nameWithUrl:request.URL.absoluteString suffix:HLS_SUFFIX_TS];
    __block id<HLSAssetTsContent>_ts = nil;
    mcs_queue_sync(^{
        // range
        BOOL isRangeRequest = MCSRequestIsRangeRequest(request);
        NSRange requestRange = NSMakeRange(0, 0);
        if ( isRangeRequest ) {
            MCSRequestContentRange contentRange = MCSRequestGetContentRange(request.allHTTPHeaderFields);
            requestRange = MCSRequestRange(contentRange);
        }
        
        for ( id<HLSAssetTsContent>cur in mTsContents ) {
            if ( ![cur.name isEqualToString:name] )
                continue;
            if ( isRangeRequest && !NSEqualRanges(requestRange, cur.rangeInAsset) )
                continue;

            // 已缓存完毕
            if ( cur.length == cur.rangeInAsset.length ) {
                _ts = cur;
                break;
            }
            
            // 未缓存完成的, 则返回length最长的content
            if ( cur.readwriteCount == 0 ) {
                if ( _ts.length < cur.length ) {
                    _ts = cur;
                }
            }
        }
        
        if ( _ts != nil ) {
            [_ts readwriteRetain];
        }
    });
    return _ts;
}

- (nullable id<MCSAssetContent>)createContentReadwriteWithDataType:(MCSDataType)dataType response:(id<MCSDownloadResponse>)response {
    switch ( dataType ) {
        case MCSDataTypeHLSMask:
        case MCSDataTypeHLSPlaylist:
        case MCSDataTypeHLSAESKey:
        case MCSDataTypeHLS:
        case MCSDataTypeFILEMask:
        case MCSDataTypeFILE:
            /* return */
            return nil;
        case MCSDataTypeHLSTs:
            break;
    }
    
    NSString *TsContentType = response.contentType;
    __block BOOL isUpdated = NO;
    __block id<HLSAssetTsContent>content = nil;
    mcs_queue_sync(^{
        if ( ![TsContentType isEqualToString:_TsContentType] ) {
            _TsContentType = TsContentType;
            isUpdated = YES;
        }
        
        NSString *name = [MCSURL.shared nameWithUrl:response.URL.absoluteString suffix:HLS_SUFFIX_TS];
        
        if ( response.statusCode == MCS_RESPONSE_CODE_PARTIAL_CONTENT ) {
            content = [mProvider createTsContentWithName:name totalLength:response.totalLength rangeInAsset:response.range];
        }
        else {
            content = [mProvider createTsContentWithName:name totalLength:response.totalLength];
        }
        [content readwriteRetain];
        [mTsContents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}

#pragma mark - readwrite

- (void)readwriteCountDidChange:(NSInteger)count {
    if ( count == 0 ) {
        [self _mergeContents];
    }
}

// 合并文件
- (void)_mergeContents {
    if ( _root != nil && _root.readwriteCount != 0 ) return;
    if ( self.readwriteCount != 0 ) return;
    if ( _isStored ) return;
    if ( mTsContents.count == 0 ) return;
    
    NSMutableArray<id<HLSAssetTsContent>> *contents = mTsContents.copy;
    NSMutableArray<id<HLSAssetTsContent>> *deletes = NSMutableArray.alloc.init;
    for ( NSInteger i = 0 ; i < contents.count ; ++ i ) {
        id<HLSAssetTsContent>obj1 = contents[i];
        for ( NSInteger j = i + 1 ; j < contents.count ; ++ j ) {
            id<HLSAssetTsContent>obj2 = contents[j];
            if ( [obj1.name isEqualToString:obj2.name] && NSEqualRanges(obj1.rangeInAsset, obj2.rangeInAsset) ) {
                [deletes addObject:obj1.length >= obj2.length ? obj2 : obj1];
            }
        }
    }
    
    if ( deletes.count != 0 ) {
        for ( id<HLSAssetTsContent>content in deletes ) { [mProvider removeTsContent:content]; }
        [mTsContents removeObjectsInArray:deletes];
    }
    
    if ( mTsContents.count == _parser.tsCount ) {
        BOOL isStoredAllContents = YES;
        for ( id<HLSAssetTsContent>content in mTsContents ) {
            if ( content.length != content.totalLength ) {
                isStoredAllContents = NO;
                break;
            }
        }
        _isStored = isStoredAllContents;
    }
}
@end
