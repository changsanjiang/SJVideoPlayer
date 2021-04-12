//
//  HLSParser.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSParser.h"
#import "MCSError.h"
#import "MCSContents.h"
#import "MCSURL.h"
#import "NSURLRequest+MCS.h"
#import "MCSQueue.h"
#import "HLSAsset.h"
#import "MCSConsts.h"
#import "MCSUtils.h"

// https://tools.ietf.org/html/rfc8216

#define HLS_PREFIX_TAG                  @"#"
#define HLS_SUFFIX_CONTINUE             @"\\"

#define HLS_PREFIX_FILE_FIRST_LINE      @"#EXTM3U"
#define HLS_PREFIX_TS_DURATION          @"#EXTINF:"
#define HLS_PREFIX_TS_BYTERANGE         @"#EXT-X-BYTERANGE:"
#define HLS_PREFIX_AESKEY               @"#EXT-X-KEY:METHOD=AES-128"
#define HLS_PREFIX_MEDIA                @"#EXT-X-MEDIA:"
#define HLS_PREFIX_VARIANT_STREAM       @"#EXT-X-STREAM-INF:"
#define HLS_PREFIX_I_FRAME_STREAM       @"#EXT-X-I-FRAME-STREAM-INF:"

// #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="English stereo",LANGUAGE="en",AUTOSELECT=YES,URI="audio.m3u8"
#define HLS_MEDIA_TYPE_AUDIO            @"AUDIO"
#define HLS_MEDIA_TYPE_VIDEO            @"VIDEO"
#define HLS_MEDIA_TYPE_SUBTITLES        @"SUBTITLES"
#define HLS_MEDIA_TYPE_CLOSED_CAPTIONS  @"CLOSED-CAPTIONS"

#define HLS_REGEX_MEDIA_URI             @"#EXT-X-MEDIA:.+URI=\"(.*)\"[^\\s]*"
#define HLS_INDEX_MEDIA_URI             1
#define HLS_REGEX_MEDIA_TYPE_AND_GROUP_ID @"TYPE=([^,]+)|GROUP-ID=\\\"([^\\\"]+)\\\""
#define HLS_INDEX_MEDIA_TYPE            1
#define HLS_INDEX_MEDIA_GROUP_ID        2

// #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=3359000,RESOLUTION=608x1080,CODECS="avc1.4d001f,mp4a.40.5",AUDIO="...",SUBTITLES="...",VIDEO="..."
// video.m3u8
#define HLS_REGEX_VARIANT_STREAM        @"#EXT-X-STREAM-INF.+\\s(.+)\\s"
#define HLS_INDEX_VARIANT_STREAM        1
#define HLS_REGEX_RENDITIONS            @"AUDIO=\"([^\"]+)\"|VIDEO=\"([^\"]+)\"|SUBTITLES=\"([^\"]+)\"|CLOSED-CAPTIONS=\"([^\"]+)\""
#define HLS_INDEX_RENDITIONS_AUDIO      1
#define HLS_INDEX_RENDITIONS_VIDEO      2
#define HLS_INDEX_RENDITIONS_SUBTITLES  3
#define HLS_INDEX_RENDITIONS_CLOSED_CAPTIONS  4

// #EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=42029000,CODECS="avc1.4d001f",URI="iframe.m3u8"
#define HLS_REGEX_I_FRAME_STREAM        @"#EXT-X-I-FRAME-STREAM-INF:.+URI=\"(.*)\"[^\\s]*"
#define HLS_INDEX_I_FRAME_STREAM        1

// #EXT-X-KEY:METHOD=AES-128,URI="...",IV=...
#define HLS_REGEX_AESKEY                @"#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\""
#define HLS_INDEX_AESKEY_URI            1

// #EXTINF:10,
// #EXT-X-BYTERANGE:1007868@0
// 000000.ts
// #EXT-X-BYTERANGE:1234567
#define HLS_REGEX_TS_BYTERANGE_START    @"#EXT-X-BYTERANGE:.+@(.+)"
#define HLS_REGEX_TS_BYTERANGE_LENGTH   @"#EXT-X-BYTERANGE:([^@]+)"
#define HLS_INDEX_TS_BYTERANGE_START    1
#define HLS_INDEX_TS_BYTERANGE_LENGTH   1

typedef NS_ENUM(NSUInteger, HLSMatchedContentsOperation) {
    HLSMatchedContentsOperationReplaceToProxyURI,
    HLSMatchedContentsOperationDelete,
};

static dispatch_queue_t mcs_queue;

@interface NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (nullable NSArray<NSTextCheckingResult *> *)mcs_textCheckingResultsByMatchPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
@end

@interface HLSURIItem : NSObject<HLSURIItem>
- (instancetype)initWithType:(MCSDataType)type URI:(NSString *)URI HTTPAdditionalHeaders:(nullable NSDictionary *)HTTPAdditionalHeaders;
/// MCSDataTypeHLSAESKey    = 2,
/// MCSDataTypeHLSTs        = 3,
@property (nonatomic) MCSDataType type;
@property (nonatomic, copy) NSString *URI;
@property (nonatomic, copy, nullable) NSDictionary *HTTPAdditionalHeaders;

// #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=3359000,RESOLUTION=608x1080,CODECS="avc1.4d001f,mp4a.40.5",AUDIO="...",SUBTITLES="...",VIDEO="..."
@property (nonatomic) BOOL isVariantItem;
@property (nonatomic, copy, nullable) NSString *groupId;
@property (nonatomic, strong, nullable) HLSURIItem *audioRenditions;
@property (nonatomic, strong, nullable) HLSURIItem *videoRenditions;
@property (nonatomic, strong, nullable) HLSURIItem *subtitleRenditions;
@property (nonatomic, strong, nullable) HLSURIItem *closedCaptionsRenditions;
@end

@implementation HLSURIItem
- (instancetype)initWithType:(MCSDataType)type URI:(NSString *)URI HTTPAdditionalHeaders:(nullable NSDictionary *)HTTPAdditionalHeaders {
    self = [super init];
    if ( self ) {
        _type = type;
        _URI = URI.copy;
        _HTTPAdditionalHeaders = HTTPAdditionalHeaders.copy;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { type: %lu, URI: %@, HTTPAdditionalHeaders: %@\n };", NSStringFromClass(self.class), self, (unsigned long)_type, _URI, _HTTPAdditionalHeaders];
}
@end

@interface NSString (MCSHLSContents)
- (nullable NSArray<NSString *> *)mcs_urlsByMatchingPattern:(NSString *)pattern contentsURL:(NSURL *)contentsURL options:(NSRegularExpressionOptions)options;
- (nullable NSArray<NSString *> *)mcs_urlsByMatchingPattern:(NSString *)pattern atIndex:(NSInteger)index contentsURL:(NSURL *)contentsURL options:(NSRegularExpressionOptions)options;
- (NSString *)mcs_convertToUrlByContentsURL:(NSURL *)contentsURL;

- (nullable NSArray<NSValue *> *)mcs_TsURIRanges;
- (nullable NSArray<HLSURIItem *> *)mcs_URIItems;

@property (nonatomic, readonly) BOOL mcs_hasVariantStream;
@end

@interface NSArray<ObjectType> (HLSURIItems)
- (nullable ObjectType)mcs_firstObject:(BOOL(^)(ObjectType obj))block;
@end

@interface HLSParser () {
    float _networkTaskPriority;
    BOOL _isCalledPrepare;
    NSURLRequest *_request;
    NSArray<HLSURIItem *> *_Nullable _URIItems;
    NSArray<HLSURIItem *> *_Nullable _TsArray;
    id<HLSParserDelegate> _Nullable _delegate;
}
@end

@implementation HLSParser
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = mcs_dispatch_queue_create("queue.HLSParser", DISPATCH_QUEUE_CONCURRENT);
    });
}

+ (nullable instancetype)parserInAsset:(HLSAsset *)asset {
    NSParameterAssert(asset);
    NSString *filePath = [asset indexFilePath];
    // 已解析过, 将直接读取本地
    if ( [NSFileManager.defaultManager fileExistsAtPath:filePath] ) {
        HLSParser *parser = HLSParser.alloc.init;
        parser->_asset = asset;
        [parser _finished];
        return parser;
    }
    return nil;
}

- (instancetype)initWithAsset:(HLSAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<HLSParserDelegate>)delegate {
    self = [self init];
    if ( self ) {
        NSParameterAssert(asset);
        _asset = asset;
        _networkTaskPriority = networkTaskPriority;
        _request = request;
        _delegate = delegate;
    }
    return self;
}

- (NSUInteger)allItemsCount {
    __block NSUInteger count = 0;
    dispatch_sync(mcs_queue, ^{
        count = _URIItems.count;
    });
    return count;
}

- (NSUInteger)tsCount {
    __block NSUInteger count = 0;
    dispatch_sync(mcs_queue, ^{
        count = _TsArray.count;
    });
    return count;
}

- (nullable id<HLSURIItem>)itemAtIndex:(NSUInteger)index {
    __block HLSURIItem *item = nil;
    dispatch_sync(mcs_queue, ^{
        item = index < _URIItems.count ? _URIItems[index] : nil;
    });
    return item;
}

- (BOOL)isVariantItem:(id<HLSURIItem>)item {
    return [(HLSURIItem *)item isVariantItem];
}
// AUDIO="...",SUBTITLES="...",VIDEO="..."
- (nullable NSArray<id<HLSURIItem>> *)renditionsItemsForVariantItem:(id<HLSURIItem>)item {
    HLSURIItem *obj = item;
    // https://tools.ietf.org/html/rfc8216#section-4.3.4.2
    if ( obj.isVariantItem ) {
        NSMutableArray<HLSURIItem *> *m = [NSMutableArray arrayWithCapacity:3];
        if ( obj.audioRenditions != nil )
            [m addObject:obj.audioRenditions];
        if ( obj.videoRenditions != nil )
            [m addObject:obj.videoRenditions];
        if ( obj.subtitleRenditions != nil )
            [m addObject:obj.subtitleRenditions];
        if ( obj.closedCaptionsRenditions != nil )
            [m addObject:obj.closedCaptionsRenditions];
        return m.count > 0 ? m : nil;
    }
    return nil;
}

- (nullable id<HLSURIItem>)tsAtIndex:(NSUInteger)index {
    __block HLSURIItem *item = nil;
    dispatch_sync(mcs_queue, ^{
        item = index < _TsArray.count ? _TsArray[index] : nil;
    });
    return item;
}

- (void)prepare {
    dispatch_barrier_async(mcs_queue, ^{
        if ( self->_isClosed || self->_isCalledPrepare )
            return;
        
        self->_isCalledPrepare = YES;
        
        [self _start];
    });
}

- (void)close {
    dispatch_barrier_sync(mcs_queue, ^{
        [self _close];
    });
}

@synthesize isDone = _isDone;
- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(mcs_queue, ^{
        isDone = _isDone;
    });
    return isDone;
}

@synthesize isClosed = _isClosed;
- (BOOL)isClosed {
    __block BOOL isClosed = NO;
    dispatch_sync(mcs_queue, ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

#pragma mark -

- (void)_start {
    
    NSString *indexFilePath = [_asset indexFilePath];
    // 已解析过, 将直接读取本地
    if ( [NSFileManager.defaultManager fileExistsAtPath:indexFilePath] ) {
        [self _finished];
        return;
    }
    
    HLSAsset *asset = _asset;
    
    if ( asset == nil ) {
        [self _close];
        return;
    }
    
    __block NSURLRequest *currRequest = _request;
    __weak typeof(self) _self = self;
    [MCSContents request:currRequest networkTaskPriority:_networkTaskPriority willPerformHTTPRedirection:^(NSURLRequest * _Nonnull newRequest) {
        currRequest = newRequest;
    } completed:^(NSData * _Nullable data, NSError * _Nullable error) {
        dispatch_barrier_sync(mcs_queue, ^{
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            [self _parseContentsWithRequest:currRequest data:data error:error];
        });
    }];
}

- (void)_parseContentsWithRequest:(NSURLRequest *)currRequest data:(NSData *)data error:(NSError *)error {
    if ( _isClosed ) {
        return;
    }
    
    HLSAsset *asset = _asset;
    if ( asset == nil ) {
        [self _close];
        return;
    }
    
    if ( error != nil ) {
        [self _onError:[NSError mcs_errorWithCode:MCSUnknownError userInfo:@{
            MCSErrorUserInfoObjectKey : currRequest,
            MCSErrorUserInfoErrorKey : error,
            MCSErrorUserInfoReasonKey : @"下载数据失败!"
        }]];
        return;
    }
    
    NSString *_Nullable contents = [NSString.alloc initWithData:data encoding:1];
    
    if ( contents == nil || ![contents hasPrefix:HLS_PREFIX_FILE_FIRST_LINE] ) {
        [self _onError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
            MCSErrorUserInfoObjectKey : contents ?: @"",
            MCSErrorUserInfoReasonKey : @"数据为空或格式不正确!"
        }]];
        return;
    }
    
    NSMutableString *indexFileContents = contents.mutableCopy;
    
    // #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="English stereo",LANGUAGE="en",AUTOSELECT=YES,URI="audio.m3u8"
    [self _contents:indexFileContents matchingPattern:HLS_REGEX_MEDIA_URI atIndex:HLS_INDEX_MEDIA_URI suffix:HLS_SUFFIX_INDEX contentsURL:currRequest.URL options:kNilOptions operation:^HLSMatchedContentsOperation(NSUInteger idx) {
        return HLSMatchedContentsOperationReplaceToProxyURI;
    }];
    
    // #EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=42029000,CODECS="avc1.4d001f",URI="iframe.m3u8"
    [self _contents:indexFileContents matchingPattern:HLS_REGEX_I_FRAME_STREAM atIndex:HLS_INDEX_I_FRAME_STREAM suffix:HLS_SUFFIX_INDEX contentsURL:currRequest.URL options:kNilOptions operation:^HLSMatchedContentsOperation(NSUInteger idx) {
        return HLSMatchedContentsOperationReplaceToProxyURI;
    }];
    
    // #EXT-X-STREAM-INF:BANDWIDTH=928000,CODECS="avc1.42c00d,mp4a.40.2",RESOLUTION=480x270,AUDIO="audio"
    // video.m3u8
    [self _contents:indexFileContents matchingPattern:HLS_REGEX_VARIANT_STREAM atIndex:HLS_INDEX_VARIANT_STREAM suffix:HLS_SUFFIX_INDEX contentsURL:currRequest.URL options:kNilOptions operation:^HLSMatchedContentsOperation(NSUInteger idx) {
        return idx == 0 ? HLSMatchedContentsOperationReplaceToProxyURI : HLSMatchedContentsOperationDelete;
    }];
    
    // #EXT-X-KEY:METHOD=AES-128,URI="...",IV=...
    [self _contents:indexFileContents matchingPattern:HLS_REGEX_AESKEY atIndex:HLS_INDEX_AESKEY_URI suffix:HLS_SUFFIX_AES_KEY contentsURL:currRequest.URL options:kNilOptions operation:^HLSMatchedContentsOperation(NSUInteger idx) {
        return HLSMatchedContentsOperationReplaceToProxyURI;
    }];
    
    // #EXTINF:10,
    // #EXT-X-BYTERANGE:1007868@0
    // 000000.ts
    NSArray<NSValue *> *TsURIRanges = [indexFileContents mcs_TsURIRanges];
    if ( TsURIRanges.count != 0 ) {
        [TsURIRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj rangeValue];
            NSString *matched = [indexFileContents substringWithRange:range];
            NSString *url = [matched mcs_convertToUrlByContentsURL:currRequest.URL];
            NSString *proxy = [MCSURL.shared HLS_proxyURIWithURL:url suffix:HLS_SUFFIX_TS inAsset:asset.name];
            [indexFileContents replaceCharactersInRange:range withString:proxy];
        }];
    }
    
    NSString *indexFilePath = [asset indexFilePath];
    if ( ![NSFileManager.defaultManager fileExistsAtPath:indexFilePath] ) {
        NSError *_Nullable error = nil;
        if ( ![indexFileContents writeToFile:indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
            [self _onError:error];
            return;
        }
    }
    
    [self _finished];
}

- (void)_contents:(NSMutableString *)contents matchingPattern:(NSString *)pattern atIndex:(NSInteger)index suffix:(NSString *)suffix contentsURL:(NSURL *)contentsURL options:(NSRegularExpressionOptions)options operation:(HLSMatchedContentsOperation(^)(NSUInteger idx))operationBlock {
    [[contents mcs_textCheckingResultsByMatchPattern:pattern options:kNilOptions] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        HLSMatchedContentsOperation operation = operationBlock(idx);
        switch ( operation ) {
            case HLSMatchedContentsOperationReplaceToProxyURI: {
                NSRange URIRange = [result rangeAtIndex:index];
                NSString *URI = [contents substringWithRange:URIRange];
                NSString *url = [URI mcs_convertToUrlByContentsURL:contentsURL];
                NSString *proxy = [MCSURL.shared HLS_proxyURIWithURL:url suffix:suffix inAsset:_asset.name];
                [contents replaceCharactersInRange:URIRange withString:proxy];
            }
                break;
            case HLSMatchedContentsOperationDelete: {
                [contents deleteCharactersInRange:result.range];
            }
                break;
        }
    }];
}

- (void)_onError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"%d - %s - %@", (int)__LINE__, __func__, error);
#endif
    [self _close];
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate parser:self anErrorOccurred:error];
    });
}

- (void)_finished {
    if ( _isClosed )
        return;
    
    NSString *indexFilePath = [_asset indexFilePath];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:indexFilePath encoding:NSUTF8StringEncoding error:&error];
    if ( content == nil ) {
        [self _onError:error];
        return;
    }
    
    _URIItems = [content mcs_URIItems];
    NSMutableArray<HLSURIItem *> *_Nullable TsItems = NSMutableArray.array;
    for ( HLSURIItem *item in _URIItems ) {
        if ( item.type == MCSDataTypeHLSTs ) [TsItems addObject:item];
    }
    _TsArray = TsItems.count != 0 ? TsItems.copy : nil;
    _isDone = YES;
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate parserParseDidFinish:self];
    });
}

- (void)_close {
    if ( _isClosed ) return;
    _isClosed = YES;
}
@end

@implementation NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSMutableArray<NSValue *> *m = NSMutableArray.array;
    for ( NSTextCheckingResult *result in [self mcs_textCheckingResultsByMatchPattern:pattern options:options])
        [m addObject:[NSValue valueWithRange:result.range]];
    return m.count != 0 ? m.copy : nil;
}

- (nullable NSArray<NSTextCheckingResult *> *)mcs_textCheckingResultsByMatchPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:NULL];
    NSMutableArray<NSTextCheckingResult *> *m = NSMutableArray.array;
    [regex enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if ( result != nil ) {
            [m addObject:result];
        }
    }];
    return m.count != 0 ? m.copy : nil;
}
@end

@implementation NSString (MCSHLSContents)
- (nullable NSArray<NSString *> *)mcs_urlsByMatchingPattern:(NSString *)pattern contentsURL:(NSURL *)contentsURL options:(NSRegularExpressionOptions)options {
    return [self mcs_urlsByMatchingPattern:pattern atIndex:0 contentsURL:contentsURL options:options];
}

- (nullable NSArray<NSString *> *)mcs_urlsByMatchingPattern:(NSString *)pattern atIndex:(NSInteger)index contentsURL:(NSURL *)contentsURL options:(NSRegularExpressionOptions)options {
    NSMutableArray<NSString *> *m = NSMutableArray.array;
    [[self mcs_textCheckingResultsByMatchPattern:pattern options:options] enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        The range at index 0 always matches the range property.  Additional ranges, if any, will have indexes from 1 to numberOfRanges-1. rangeWithName: can be used with named regular expression capture groups
        NSRange range = [obj rangeAtIndex:index];
        NSString *matched = [self substringWithRange:range];
        NSString *url = [matched mcs_convertToUrlByContentsURL:contentsURL];
        [m addObject:url];
    }];
    return m.count != 0 ? m.copy : nil;
}

/// 将路径转换为url
- (NSString *)mcs_convertToUrlByContentsURL:(NSURL *)URL {
    static NSString *const HLS_PREFIX_LOCALHOST = @"http://localhost";
    static NSString *const HLS_PREFIX_DIR_ROOT = @"/";
    static NSString *const HLS_PREFIX_DIR_PARENT = @"../";
    static NSString *const HLS_PREFIX_DIR_CURRENT = @"./";
     
    NSString *url = nil;
    if      ( [self hasPrefix:HLS_PREFIX_DIR_ROOT] ) {
        NSURL *rootDir = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", URL.scheme, URL.host]];
        NSString *subpath = self;
        url = [rootDir mcs_URLByAppendingPathComponent:subpath].absoluteString;
    }
    else if ( [self hasPrefix:HLS_PREFIX_DIR_PARENT] ) {
        NSURL *curDir = URL.mcs_URLByDeletingLastPathComponentAndQuery;
        NSURL *parentDir = curDir.mcs_URLByDeletingLastPathComponentAndQuery;
        NSString *subpath = [self substringFromIndex:HLS_PREFIX_DIR_PARENT.length];
        url = [parentDir mcs_URLByAppendingPathComponent:subpath].absoluteString;
    }
    else if ( [self hasPrefix:HLS_PREFIX_DIR_CURRENT] ) {
        NSURL *curDir = URL.mcs_URLByDeletingLastPathComponentAndQuery;
        NSString *subpath = [self substringFromIndex:HLS_PREFIX_DIR_CURRENT.length];
        url = [curDir mcs_URLByAppendingPathComponent:subpath].absoluteString;
    }
    else if ( [self hasPrefix:HLS_PREFIX_LOCALHOST] ) {
        NSURL *rootDir = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", URL.scheme, URL.host]];
        NSString *subpath = [self substringFromIndex:HLS_PREFIX_LOCALHOST.length];
        url = [rootDir mcs_URLByAppendingPathComponent:subpath].absoluteString;
    }
    else if ( [self containsString:@"://"] ) {
        url = self;
    }
    else {
        NSURL *curDir = URL.mcs_URLByDeletingLastPathComponentAndQuery;
        NSString *subpath = self;
        url = [curDir mcs_URLByAppendingPathComponent:subpath].absoluteString;
    }
    return url;
}

- (nullable NSArray<NSValue *> *)mcs_TsURIRanges {
    NSArray<NSString *> *lines = [self componentsSeparatedByString:@"\n"];
    NSMutableArray<NSValue *> *m = nil;
    BOOL tsFlag = NO;
    NSInteger length = 0;
    for ( NSString *line in lines ) {
        if      ( [line hasPrefix:HLS_PREFIX_TS_DURATION] ) {
            tsFlag = YES;
        }
        else if ( tsFlag && ![line hasPrefix:HLS_PREFIX_TAG] && ![line hasSuffix:HLS_SUFFIX_CONTINUE] ) {
            if ( m == nil ) m = NSMutableArray.array;
            [m addObject:[NSValue valueWithRange:NSMakeRange(length, line.length)]];
            tsFlag = NO;
        }
        
        length += line.length + 1;
    }
    return m.copy;
}

- (nullable NSArray<HLSURIItem *> *)mcs_URIItems {
    NSArray<NSString *> *lines = [self componentsSeparatedByString:@"\n"];
    NSMutableArray<HLSURIItem *> *m = NSMutableArray.array;
    NSMutableArray<HLSURIItem *> *audioRenditionsArray = nil;
    NSMutableArray<HLSURIItem *> *videoRenditionsArray = nil;
    NSMutableArray<HLSURIItem *> *subtitleRenditionsArray = nil;
    NSMutableArray<HLSURIItem *> *closedCaptionsRenditionsArray = nil;
    BOOL tsFlag = NO;
    BOOL vsFlag = NO;
    NSString *audioGroupId = nil;
    NSString *videoGroupId = nil;
    NSString *subtitleGroupId = nil;
    NSString *closedCaptionsGroupId = nil;
    NSRange bytesRange = NSMakeRange(0, 0);
    NSUInteger bytesNextPosition = 0;
    for ( NSString *line in lines ) {
        // #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="English stereo",LANGUAGE="en",AUTOSELECT=YES,URI="audio.m3u8"
        if      ( [line hasPrefix:HLS_PREFIX_MEDIA] ) {
            NSArray<NSTextCheckingResult *> *results = [line mcs_textCheckingResultsByMatchPattern:HLS_REGEX_MEDIA_TYPE_AND_GROUP_ID options:kNilOptions];
            NSTextCheckingResult *typeCheckingResult = results.firstObject;
            NSRange typeRange = [typeCheckingResult rangeAtIndex:HLS_INDEX_MEDIA_TYPE];
            NSString *type = [line substringWithRange:typeRange];
            
            NSTextCheckingResult *groupIdCheckingResult = results.lastObject;
            NSRange groupIdRange = [groupIdCheckingResult rangeAtIndex:HLS_INDEX_MEDIA_GROUP_ID];
            NSString *groupId = [line substringWithRange:groupIdRange];
            
            NSTextCheckingResult *URICheckingResult = [line mcs_textCheckingResultsByMatchPattern:HLS_REGEX_MEDIA_URI options:kNilOptions].firstObject;
            NSRange URIRange = [URICheckingResult rangeAtIndex:HLS_INDEX_MEDIA_URI];
            NSString *URI = [line substringWithRange:URIRange];
            
            HLSURIItem *item = [HLSURIItem.alloc initWithType:MCSDataTypeHLSPlaylist URI:URI HTTPAdditionalHeaders:nil];
            item.groupId = groupId;
            if      ( [type isEqualToString:HLS_MEDIA_TYPE_AUDIO] ) {
                if ( audioRenditionsArray == nil )
                    audioRenditionsArray = NSMutableArray.array;
                [audioRenditionsArray addObject:item];
            }
            else if ( [type isEqualToString:HLS_MEDIA_TYPE_VIDEO] ) {
                if ( videoRenditionsArray == nil )
                    videoRenditionsArray = NSMutableArray.array;
                [videoRenditionsArray addObject:item];
            }
            else if ( [type isEqualToString:HLS_MEDIA_TYPE_SUBTITLES] ) {
                if ( subtitleRenditionsArray == nil )
                    subtitleRenditionsArray = NSMutableArray.array;
                [subtitleRenditionsArray addObject:item];
            }
            else if ( [type isEqualToString:HLS_MEDIA_TYPE_CLOSED_CAPTIONS] ) {
                if ( closedCaptionsRenditionsArray == nil )
                    closedCaptionsRenditionsArray = NSMutableArray.array;
                [closedCaptionsRenditionsArray addObject:item];
            }
        }
        // #EXT-X-STREAM-INF:BANDWIDTH=928000,CODECS="avc1.42c00d,mp4a.40.2",RESOLUTION=480x270,AUDIO="...",SUBTITLES="...",VIDEO="..."
        else if ( [line hasPrefix:HLS_PREFIX_VARIANT_STREAM] ) {
            vsFlag = YES;
            audioGroupId = videoGroupId = subtitleGroupId = closedCaptionsGroupId = nil;
            for ( NSTextCheckingResult *result in [line mcs_textCheckingResultsByMatchPattern:HLS_REGEX_RENDITIONS options:kNilOptions] ) {
                NSRange audioGroupIdRange = [result rangeAtIndex:HLS_INDEX_RENDITIONS_AUDIO];
                NSRange videoGroupIdRange = [result rangeAtIndex:HLS_INDEX_RENDITIONS_VIDEO];
                NSRange subtitleGroupIdRange = [result rangeAtIndex:HLS_INDEX_RENDITIONS_SUBTITLES];
                NSRange closedCaptionsGroupIdRange = [result rangeAtIndex:HLS_INDEX_RENDITIONS_CLOSED_CAPTIONS];
                if ( audioGroupIdRange.length != 0 ) audioGroupId = [line substringWithRange:audioGroupIdRange];
                if ( videoGroupIdRange.length != 0 ) videoGroupId = [line substringWithRange:videoGroupIdRange];
                if ( subtitleGroupIdRange.length != 0 ) subtitleGroupId = [line substringWithRange:subtitleGroupIdRange];
                if ( closedCaptionsGroupIdRange.length != 0 ) closedCaptionsGroupId = [line substringWithRange:closedCaptionsGroupIdRange];
            }
        }
        else if ( vsFlag ) {
            if ( ![line hasPrefix:HLS_PREFIX_TAG] && ![line hasSuffix:HLS_SUFFIX_CONTINUE] ) {
                NSString *URI = line;
                HLSURIItem *item = [HLSURIItem.alloc initWithType:MCSDataTypeHLSPlaylist URI:URI HTTPAdditionalHeaders:nil];
                item.isVariantItem = YES;
                item.audioRenditions = [audioRenditionsArray mcs_firstObject:^BOOL(HLSURIItem *obj) {
                    return [obj.groupId isEqualToString:audioGroupId];
                }];
                item.videoRenditions = [videoRenditionsArray mcs_firstObject:^BOOL(HLSURIItem *obj) {
                    return [obj.groupId isEqualToString:videoGroupId];
                }];
                item.subtitleRenditions = [subtitleRenditionsArray mcs_firstObject:^BOOL(HLSURIItem *obj) {
                    return [obj.groupId isEqualToString:subtitleGroupId];
                }];
                item.closedCaptionsRenditions = [closedCaptionsRenditionsArray mcs_firstObject:^BOOL(HLSURIItem *obj) {
                    return [obj.groupId isEqualToString:closedCaptionsGroupId];
                }];
                [m addObject:item];
                vsFlag = NO;
            }
        }
        //    #EXT-X-KEY:METHOD=AES-128,URI="key1.php"
        //
        //    #EXTINF:2.833,
        //    example/0.ts
        //    #EXTINF:15.0,
        //    example/1.ts
        //
        //    #EXT-X-KEY:METHOD=AES-128,URI="key2.php"
        //
        else if ( [line hasPrefix:HLS_PREFIX_AESKEY] ) {
            NSTextCheckingResult *result = [line mcs_textCheckingResultsByMatchPattern:HLS_REGEX_AESKEY options:kNilOptions].firstObject;
            NSRange range = [result rangeAtIndex:HLS_INDEX_AESKEY_URI];
            NSString *URI = [line substringWithRange:range];
            [m addObject:[HLSURIItem.alloc initWithType:MCSDataTypeHLSAESKey URI:URI HTTPAdditionalHeaders:nil]];
        }
        else if ( [line hasPrefix:HLS_PREFIX_TS_DURATION] ) {
            tsFlag = YES;
        }
        else if ( tsFlag ) {
            if      ( [line hasPrefix:HLS_PREFIX_TS_BYTERANGE] ) {
                NSTextCheckingResult *startCheckingResult = [line mcs_textCheckingResultsByMatchPattern:HLS_REGEX_TS_BYTERANGE_START options:kNilOptions].firstObject;
                NSRange startRange = [startCheckingResult rangeAtIndex:HLS_INDEX_TS_BYTERANGE_START];
                long long start = startRange.length != 0 ? [line substringWithRange:startRange].longLongValue : bytesNextPosition;
                
                NSTextCheckingResult *lengthCheckingResult = [line mcs_textCheckingResultsByMatchPattern:HLS_REGEX_TS_BYTERANGE_LENGTH options:kNilOptions].firstObject;
                NSRange lengthRange = [lengthCheckingResult rangeAtIndex:HLS_INDEX_TS_BYTERANGE_LENGTH];
                long long length = [line substringWithRange:lengthRange].longLongValue;
                
                bytesRange = NSMakeRange(start, length);
                bytesNextPosition = start + length;
            }
            else if ( ![line hasPrefix:HLS_PREFIX_TAG] && ![line hasSuffix:HLS_SUFFIX_CONTINUE] ) {
                NSString *URI = line;
                NSDictionary *headers = nil;
                if ( bytesRange.length != 0 )
                    headers = @{
                        @"Range" : [NSString stringWithFormat:@"bytes=%lu-%lu", (unsigned long)bytesRange.location, NSMaxRange(bytesRange) - 1]
                    };
                [m addObject:[HLSURIItem.alloc initWithType:MCSDataTypeHLSTs URI:URI HTTPAdditionalHeaders:headers]];
                tsFlag = NO;
            }
        }
    }
    return m.count != 0 ? m.copy : nil;
}

- (BOOL)mcs_hasVariantStream {
    return [self mcs_textCheckingResultsByMatchPattern:HLS_PREFIX_VARIANT_STREAM options:kNilOptions] != nil;
}
@end


@implementation NSArray (HLSURIItems)
- (nullable id)mcs_firstObject:(BOOL(^)(id obj))block {
    for ( id obj in self ) {
        if ( block(obj) )
            return obj;
    }
    return nil;
}
@end

/**

 https://www.toptal.com/apple/introduction-to-http-live-streaming-hls
 
 Here is an example of such an M3U8 file:

 ```
 #EXTM3U
 #EXT-X-STREAM-INF:BANDWIDTH=1296,RESOLUTION=640x360
 https://.../640x360_1200.m3u8
 #EXT-X-STREAM-INF:BANDWIDTH=264,RESOLUTION=416x234
 https://.../416x234_200.m3u8
 #EXT-X-STREAM-INF:BANDWIDTH=464,RESOLUTION=480x270
 https://.../480x270_400.m3u8
 #EXT-X-STREAM-INF:BANDWIDTH=1628,RESOLUTION=960x540
 https://.../960x540_1500.m3u8
 #EXT-X-STREAM-INF:BANDWIDTH=2628,RESOLUTION=1280x720
 https://.../1280x720_2500.m3u8
 

 
    #EXT-X-STREAM-INF:BANDWIDTH=1296,RESOLUTION=640x360
    https://.../640x360_1200.m3u8
 
    These are called variants of the same video prepared for different network speeds and screen resolutions. This specific M3U8 file (640x360_1200.m3u8) contains the video file chunks of the video resized to 640x360 pixels and prepared for bitrates of 1296kbps. Note that the reported bitrate must take into account both the video and audio streams in the video.

    The video player will usually start playing from the first stream variant (in the previous example this is 640x360_1200.m3u8). For that reason, you must take special care to decide which variant will be the first in the list. The order of the other variants isn’t important.

    If the first .ts file takes too long to download (causing “buffering”, i.e. waiting for the next chunk) the video player will switch to a to a stream with a smaller bitrate. And, of course, if it’s loaded fast enough it means that it can switch to a better quality variant, but only if it makes sense for the resolution of the display.
 
    If the first stream in the index M3U8 list isn’t the best one, the client will need one or two cycles until it settles with the right variant.

 */
