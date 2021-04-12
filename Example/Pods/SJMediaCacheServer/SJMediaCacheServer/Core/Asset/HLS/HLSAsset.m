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
#import "HLSContentProvider.h"
#import "HLSReader.h"
#import "MCSRootDirectory.h"

static dispatch_queue_t mcs_queue;

@interface HLSAsset () {
    HLSContentProvider *_provider;
    NSMutableArray<HLSContentTs *> *_contents;
    NSString *_TsContentType;
}

@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *TsContentType;
@property (nonatomic, weak, nullable) HLSAsset *root;
@end

@implementation HLSAsset
@synthesize id = _id;
@synthesize configuration = _configuration;
@synthesize readwriteCount = _readwriteCount;
@synthesize parser = _parser;
@synthesize isStored = _isStored;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = mcs_dispatch_queue_create("queue.HLSAsset", DISPATCH_QUEUE_CONCURRENT);
    });
}

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
    NSParameterAssert(self.name != nil);
    NSString *directory = [MCSRootDirectory assetPathForFilename:self.name];
    _configuration = MCSConfiguration.alloc.init;
    _provider = [HLSContentProvider.alloc initWithDirectory:directory];
    _parser = [HLSParser parserInAsset:self];
    _contents = [(_provider.TsContents ?: @[]) mutableCopy];
    [self _mergeContents];
}

- (NSString *)path {
    return [MCSRootDirectory assetPathForFilename:_name];
}

#pragma mark - mark

- (void)setParser:(nullable HLSParser *)parser {
    dispatch_barrier_sync(mcs_queue, ^{
        _parser = parser;
    });
}

- (nullable HLSParser *)parser {
    __block HLSParser *parser = nil;
    dispatch_sync(mcs_queue, ^{
        parser = _parser;
    });
    return parser;
}

- (MCSAssetType)type {
    return MCSAssetTypeHLS;
}

- (nullable NSArray<id<MCSAssetContent>> *)TsContents {
    __block NSArray<id<MCSAssetContent>> *contents;
    dispatch_sync(mcs_queue, ^{
        contents = _contents;
    });
    return contents;
}

- (BOOL)isStored {
    __block BOOL isStored = NO;
    dispatch_sync(mcs_queue, ^{
        isStored = _isStored;
    });
    return isStored;
}

- (NSString *)indexFilePath {
    return [_provider indexFilePath];
}

- (NSString *)indexFileRelativePath {
    return [_provider indexFileRelativePath];
}

- (NSString *)AESKeyFilePathWithURL:(NSURL *)URL {
    return [_provider AESKeyFilePathWithName:[MCSURL.shared nameWithUrl:URL.absoluteString suffix:HLS_SUFFIX_AES_KEY]];
}

- (nullable NSString *)TsContentType {
    __block NSString *TsContentType = nil;
    dispatch_sync(mcs_queue, ^{
        TsContentType = _TsContentType;
    });
    return TsContentType;
}

- (NSUInteger)tsCount {
    return self.parser.tsCount;
}

@synthesize root = _root;
- (void)setRoot:(nullable HLSAsset *)root {
    dispatch_barrier_sync(mcs_queue, ^{
        _root = root;
    });
}

- (nullable HLSAsset *)root {
    __block HLSAsset *root = nil;
    dispatch_sync(mcs_queue, ^{
        root = _root;
    });
    return root;
}

- (nullable id<MCSAssetContent>)createTsContentWithResponse:(id<MCSDownloadResponse>)response {
    NSString *TsContentType = response.contentType;
    __block BOOL isUpdated = NO;
    __block HLSContentTs *content = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( ![TsContentType isEqualToString:_TsContentType] ) {
            _TsContentType = TsContentType;
            isUpdated = YES;
        }
        
        NSString *name = [MCSURL.shared nameWithUrl:response.URL.absoluteString suffix:HLS_SUFFIX_TS];
        
        if ( response.statusCode == MCS_RESPONSE_CODE_PARTIAL_CONTENT ) {
            content = [_provider createTsContentWithName:name totalLength:response.totalLength inRange:response.range];
        }
        else {
            content = [_provider createTsContentWithName:name totalLength:response.totalLength];
        }
        
        [_contents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}
 
- (nullable NSString *)TsContentFilePathForFilename:(NSString *)filename {
    return [_provider TsContentFilePathForFilename:filename];
}

- (nullable id<MCSAssetContent>)TsContentForRequest:(NSURLRequest *)request {
    NSString *name = [MCSURL.shared nameWithUrl:request.URL.absoluteString suffix:HLS_SUFFIX_TS];
    __block HLSContentTs *ts = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        // range
        NSRange r = NSMakeRange(0, 0);
        BOOL isRangeRequest = MCSRequestIsRangeRequest(request);
        MCSRequestContentRange range = MCSRequestContentRangeUndefined;
        if ( isRangeRequest ) {
            range = MCSRequestGetContentRange(request.allHTTPHeaderFields);
            r = MCSRequestRange(range);
        }
        
        for ( HLSContentTs *content in _contents ) {
            if ( ![content.name isEqualToString:name] ) continue;
            if ( isRangeRequest && !NSEqualRanges(r, content.range) ) continue;
            
            if ( content.length == content.range.length ) {
                ts = content;
                break;
            }
        }
    });
    return ts;
}

/// 该操作将会对 content 进行一次 readwriteRetain, 请在不需要时, 调用一次 readwriteRelease.
- (nullable id<MCSAssetContent>)createTsContentReadwriteWithResponse:(id<MCSDownloadResponse>)response {
    NSString *TsContentType = response.contentType;
    __block BOOL isUpdated = NO;
    __block HLSContentTs *content = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( ![TsContentType isEqualToString:_TsContentType] ) {
            _TsContentType = TsContentType;
            isUpdated = YES;
        }
        
        NSString *name = [MCSURL.shared nameWithUrl:response.URL.absoluteString suffix:HLS_SUFFIX_TS];
        
        if ( response.statusCode == MCS_RESPONSE_CODE_PARTIAL_CONTENT ) {
            content = [_provider createTsContentWithName:name totalLength:response.totalLength inRange:response.range];
        }
        else {
            content = [_provider createTsContentWithName:name totalLength:response.totalLength];
        }
        [content readwriteRetain];
        [_contents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}

/// 将返回如下两种content, 如果未满足条件, 则返回nil
///
///     - 如果ts已缓存完毕, 则返回完整的content
///
///     - 如果ts被缓存了一部分(可能存在多个), 则将返回长度最长的并且readwrite为0的content
///
/// 该操作将会对 content 进行一次 readwriteRetain, 请在不需要时, 调用一次 readwriteRelease.
///
- (nullable id<MCSAssetContent>)TsContentReadwriteForRequest:(NSURLRequest *)request {
    NSString *name = [MCSURL.shared nameWithUrl:request.URL.absoluteString suffix:HLS_SUFFIX_TS];
    __block HLSContentTs *_ts = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        // range
        BOOL isRangeRequest = MCSRequestIsRangeRequest(request);
        NSRange requestRange = NSMakeRange(0, 0);
        if ( isRangeRequest ) {
            MCSRequestContentRange contentRange = MCSRequestGetContentRange(request.allHTTPHeaderFields);
            requestRange = MCSRequestRange(contentRange);
        }
        
        for ( HLSContentTs *cur in _contents ) {
            if ( ![cur.name isEqualToString:name] )
                continue;
            if ( isRangeRequest && !NSEqualRanges(requestRange, cur.range) )
                continue;

            // 已缓存完毕
            if ( cur.length == cur.range.length ) {
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

#pragma mark - readwrite

- (NSInteger)readwriteCount {
    __block NSInteger readwriteCount = 0;
    dispatch_sync(mcs_queue, ^{
        readwriteCount = _root != nil ? _root->_readwriteCount : _readwriteCount;
    });
    return readwriteCount;
}

- (void)readwriteRetain {
    [self willChangeValueForKey:kReadwriteCount];
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _root != nil )
            _root->_readwriteCount += 1;
        else
            _readwriteCount += 1;
    });
    [self didChangeValueForKey:kReadwriteCount];
}

- (void)readwriteRelease {
    [self willChangeValueForKey:kReadwriteCount];
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _root != nil) {
            if ( _root->_readwriteCount > 0 )
                _root->_readwriteCount -= 1;
        }
        else if ( _readwriteCount > 0 ) {
            _readwriteCount -= 1;
        }
    });
    [self didChangeValueForKey:kReadwriteCount];
    [self _mergeContents];
}

#pragma mark - mark

// 合并文件
- (void)_mergeContents {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _root != nil && _root->_readwriteCount != 0 ) return;
        if ( _readwriteCount != 0 ) return;
        if ( _isStored ) return;
        
        NSMutableArray<HLSContentTs *> *contents = NSMutableArray.alloc.init;
        for ( HLSContentTs *content in _contents ) { if ( content.readwriteCount == 0 ) [contents addObject:content]; }
        
        if ( contents.count == 0 ) return;
        
        NSMutableArray<HLSContentTs *> *deletes = NSMutableArray.alloc.init;
        for ( NSInteger i = 0 ; i < contents.count ; ++ i ) {
            HLSContentTs *obj1 = contents[i];
            for ( NSInteger j = i + 1 ; j < contents.count ; ++ j ) {
                HLSContentTs *obj2 = contents[j];
                if ( [obj1.name isEqualToString:obj2.name] && NSEqualRanges(obj1.range, obj2.range) ) {
                    [deletes addObject:obj1.length >= obj2.length ? obj2 : obj1];
                }
            }
        }
        
        if ( deletes.count != 0 ) {
            for ( HLSContentTs *content in deletes ) { [_provider removeTsContentForFilename:content.filename]; }
            [_contents removeObjectsInArray:deletes];
        }

        if ( _contents.count == _parser.tsCount ) {
            BOOL isStoredAllContents = YES;
            for ( HLSContentTs *content in _contents ) {
                if ( content.length != content.totalLength ) {
                    isStoredAllContents = NO;
                    break;
                }
            }
            _isStored = isStoredAllContents;
        }
    });
}
@end
