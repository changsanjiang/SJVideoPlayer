//
//  HLSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSAsset.h"
#import "MCSConfiguration.h"
#import "MCSURLRecognizer.h"
#import "MCSUtils.h"
#import "MCSConsts.h"
#import "HLSContentProvider.h"
#import "HLSReader.h"
#import "MCSRootDirectory.h"

static NSString *kLength = @"length";
static NSString *kReadwriteCount = @"readwriteCount";
static dispatch_queue_t mcs_queue;

@interface HLSAsset () {
    HLSContentProvider *_provider;
    NSMutableArray<HLSContentTs *> *_contents;
    NSString *_TsContentType;
}

@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *TsContentType;
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
        mcs_queue = dispatch_queue_create("queue.HLSAsset", DISPATCH_QUEUE_CONCURRENT);
    });
}

+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"readwriteCount", @"isStored", @"configuration", @"contents", @"parser"];
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

- (void)lock:(void (^)(void))block {
    dispatch_barrier_sync(mcs_queue, block);
}

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

- (NSString *)AESKeyFilePathWithURL:(NSURL *)URL {
    return [_provider AESKeyFilePathWithName:[MCSURLRecognizer.shared nameWithUrl:URL.absoluteString suffix:HLS_SUFFIX_AES_KEY]];
}

- (nullable NSString *)TsContentType {
    __block NSString *TsContentType = nil;
    dispatch_sync(mcs_queue, ^{
        TsContentType = _TsContentType;
    });
    return TsContentType;
}

- (NSUInteger)TsCount {
    return self.parser.TsCount;
}

- (nullable id<MCSAssetContent>)createTsContentWithResponse:(NSHTTPURLResponse *)response {
    NSString *TsContentType = MCSGetResponseContentType(response);
    __block BOOL isUpdated = NO;
    __block HLSContentTs *content = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( ![TsContentType isEqualToString:_TsContentType] ) {
            _TsContentType = TsContentType;
            isUpdated = YES;
        }
        
        NSString *name = [MCSURLRecognizer.shared nameWithUrl:response.URL.absoluteString suffix:HLS_SUFFIX_TS];
        NSUInteger totalLength = response.expectedContentLength;
        content = [_provider createTsContentWithName:name totalLength:totalLength];
        [_contents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}
 
- (nullable NSString *)TsContentFilePathForFilename:(NSString *)filename {
    return [_provider TsContentFilePathForFilename:filename];
}

- (nullable id<MCSAssetContent>)TsContentForURL:(NSURL *)URL {
    NSString *name = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString suffix:HLS_SUFFIX_TS];
    __block HLSContentTs *ts = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        for ( HLSContentTs *content in _contents ) {
            if ( [content.name isEqualToString:name] && content.length == content.totalLength ) {
                ts = content;
                break;
            }
        }
    });
    return ts;
}

#pragma mark - readwrite

- (NSInteger)readwriteCount {
    __block NSInteger readwriteCount = 0;
    dispatch_sync(mcs_queue, ^{
        readwriteCount = _readwriteCount;
    });
    return readwriteCount;
}

- (void)readwriteRetain {
    [self willChangeValueForKey:kReadwriteCount];
    dispatch_barrier_sync(mcs_queue, ^{
        _readwriteCount += 1;
    });
    [self didChangeValueForKey:kReadwriteCount];
}

- (void)readwriteRelease {
    [self willChangeValueForKey:kReadwriteCount];
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _readwriteCount > 0 ) {
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
                if ( [obj1.name isEqualToString:obj2.name] ) {
                    [deletes addObject:obj1.length >= obj2.length ? obj2 : obj1];
                }
            }
        }
        
        if ( deletes.count != 0 ) {
            for ( HLSContentTs *content in deletes ) { [_provider removeTsContentForFilename:content.filename]; }
            [_contents removeObjectsInArray:deletes];
        }

        if ( _contents.count != 0 && _contents.count == _parser.TsCount ) {
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
