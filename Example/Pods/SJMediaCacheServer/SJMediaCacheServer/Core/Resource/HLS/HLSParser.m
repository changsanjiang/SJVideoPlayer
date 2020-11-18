//
//  HLSParser.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSParser.h"
#import "MCSError.h"
#import "MCSFileManager.h"
#import "MCSData.h"
#import "MCSURLRecognizer.h"
#import "NSURLRequest+MCS.h"
#import "MCSQueue.h"

#define MCSURIMatchingPattern_Index     @".*\\.m3u8[^\\s]*"
#define MCSURIMatchingPattern_Ts        @".*\\.ts[^\\s]*"
#define MCSURIMatchingPattern_AESKey    @"#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\""
#define MCSURIMatchingPattern_URIs      @"(.*\\.ts[^\\s]*)|(#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\")"

@interface NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern;
- (nullable NSArray<NSTextCheckingResult *> *)mcs_textCheckingResultsByMatchPattern:(NSString *)pattern;
@end

@interface HLSParser ()
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, weak, nullable) id<HLSParserDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *TsURIArray;
@property (nonatomic) float networkTaskPriority;
@property (nonatomic, strong) NSArray<NSString *> *URIs;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation HLSParser
+ (nullable instancetype)parserInAssetIfExists:(NSString *)assetName {
    NSParameterAssert(assetName);
    NSString *indexFilePath = [MCSFileManager HLS_indexFilePathInAsset:assetName];
    // 已解析过, 将直接读取本地
    if ( [MCSFileManager fileExistsAtPath:indexFilePath] ) {
        HLSParser *parser = HLSParser.alloc.init;
        parser->_assetName = assetName;
        [parser _finished];
        return parser;
    }
    return nil;
}

- (instancetype)initWithAsset:(NSString *)assetName request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<HLSParserDelegate>)delegate {
    self = [self init];
    if ( self ) {
        NSParameterAssert(assetName);
        
        _networkTaskPriority = networkTaskPriority;
        _assetName = assetName;
        _request = request;
        _delegate = delegate;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _queue = dispatch_get_global_queue(0, 0);
    }
    return self;
}

- (nullable NSString *)URIAtIndex:(NSUInteger)index {
    __block NSString *URI = nil;
    dispatch_sync(_queue, ^{
        URI = index < _URIs.count ? _URIs[index] : nil;
    });
    return URI;
}

- (void)prepare {
    dispatch_barrier_async(_queue, ^{
        if ( self->_isClosed || self->_isCalledPrepare )
            return;
        
        self->_isCalledPrepare = YES;
        
        @autoreleasepool {
            [self _parse];
        }
    });
}

- (void)close {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_isClosed )
            return;
        
        self->_isClosed = YES;
    });
}

@synthesize isDone = _isDone;
- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(_queue, ^{
        isDone = self->_isDone;
    });
    return isDone;
}

@synthesize isClosed = _isClosed;
- (BOOL)isClosed {
    __block BOOL isClosed = NO;
    dispatch_sync(_queue, ^{
        isClosed = _isClosed;
    });
    return isClosed;
}

- (NSUInteger)TsCount {
    __block NSUInteger count = 0;
    dispatch_sync(_queue, ^{
        count = _TsURIArray.count;
    });
    return count;
}

- (NSString *)indexFilePath {
    return [MCSFileManager HLS_indexFilePathInAsset:_assetName];
}

#pragma mark -

- (void)_parse {
    
    NSString *indexFilePath = [MCSFileManager HLS_indexFilePathInAsset:_assetName];
    // 已解析过, 将直接读取本地
    if ( [MCSFileManager fileExistsAtPath:indexFilePath] ) {
        [self _finished];
        return;
    }
    
    NSURLRequest *currRequest = _request;
    NSString *_Nullable contents = nil;
    do {
        NSError *downloadError = nil;
        NSData *data = [MCSData dataWithContentsOfRequest:currRequest networkTaskPriority:_networkTaskPriority error:&downloadError];
        if ( downloadError != nil ) {
            [self _onError:[NSError mcs_errorWithCode:MCSUnknownError userInfo:@{
                MCSErrorUserInfoObjectKey : currRequest,
                MCSErrorUserInfoErrorKey : downloadError,
                MCSErrorUserInfoReasonKey : @"下载数据失败!"
            }]];
            return;
        }
        
        contents = [NSString.alloc initWithData:data encoding:0];
        if ( contents == nil )
            break;

        // 是否重定向
        NSString *redirectUrl = [self _urlsWithPattern:MCSURIMatchingPattern_Index indexURL:currRequest.URL source:contents].firstObject;
        if ( redirectUrl == nil ) break;
        
        currRequest = [currRequest mcs_requestWithRedirectURL:[NSURL URLWithString:redirectUrl]];
    } while ( true );
    
    if ( contents == nil || ![contents hasPrefix:@"#"] ) {
        [self _onError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
            MCSErrorUserInfoObjectKey : contents ?: @"",
            MCSErrorUserInfoReasonKey : @"数据为空或格式不正确!"
        }]];
        return;
    }
 
    NSMutableString *indexFileContents = contents.mutableCopy;
    ///
    /// 000000.ts
    ///
    NSArray<NSValue *> *TsURIRanges = [contents mcs_rangesByMatchingPattern:MCSURIMatchingPattern_Ts];
    if ( TsURIRanges.count == 0 ) {
        [self _onError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
            MCSErrorUserInfoObjectKey : contents,
            MCSErrorUserInfoReasonKey : @"数据格式不正确, 未匹配到ts文件!"
        }]];
        return;
    }
    [TsURIRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangeValue = range.rangeValue;
        NSString *matched = [contents substringWithRange:rangeValue];
        NSString *url = [self _urlWithMatchedString:matched indexURL:currRequest.URL];
        NSString *proxy = [MCSURLRecognizer.shared proxyTsURIWithUrl:url inAsset:self.assetName];
        [indexFileContents replaceCharactersInRange:rangeValue withString:proxy];
    }];
 
    ///
    /// #EXT-X-KEY:METHOD=AES-128,URI="...",IV=...
    ///
    [[indexFileContents mcs_textCheckingResultsByMatchPattern:@"#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\""] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange URIRange = [result rangeAtIndex:1];
        NSString *URI = [indexFileContents substringWithRange:URIRange];
        NSString *url = [self _urlWithMatchedString:URI indexURL:currRequest.URL];
        NSString *proxy = [MCSURLRecognizer.shared proxyAESKeyURIWithUrl:url inAsset:self.assetName];
        [indexFileContents replaceCharactersInRange:URIRange withString:proxy];
    }];
    
    [MCSFileManager lockWithBlock:^{
        if ( ![MCSFileManager fileExistsAtPath:indexFilePath] ) {
            NSError *_Nullable error = nil;
            if ( ![indexFileContents writeToFile:indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
                [self _onError:error];
                return;
            }
        }
    }];
    
    [self _finished];
}

- (nullable NSArray<NSString *> *)_urlsWithPattern:(NSString *)pattern indexURL:(NSURL *)indexURL source:(NSString *)source {
    NSMutableArray<NSString *> *m = NSMutableArray.array;
    [[source mcs_rangesByMatchingPattern:pattern] enumerateObjectsUsingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *matched = [source substringWithRange:[range rangeValue]];
        NSString *matchedUrl = [self _urlWithMatchedString:matched indexURL:indexURL];
        [m addObject:matchedUrl];
    }];
    
    return m.count != 0 ? m.copy : nil;
}

- (NSString *)_urlWithMatchedString:(NSString *)matched indexURL:(NSURL *)indexURL {
    NSString *url = nil;
    if ( [matched containsString:@"://"] ) {
        url = matched;
    }
    else if ( [matched hasPrefix:@"/"] ) {
        url = [NSString stringWithFormat:@"%@://%@%@", indexURL.scheme, indexURL.host, matched];
    }
    else {
        url = [NSString stringWithFormat:@"%@/%@", indexURL.absoluteString.stringByDeletingLastPathComponent, matched];
    }
    return url;
}

- (void)_onError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"%d - %s - %@", (int)__LINE__, __func__, error);
#endif
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate parser:self anErrorOccurred:error];
    });
}

- (void)_finished {
    if ( _isClosed )
        return;
    
    NSString *indexFilePath = [MCSFileManager HLS_indexFilePathInAsset:_assetName];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:indexFilePath encoding:NSUTF8StringEncoding error:&error];
    if ( content == nil ) {
        [self _onError:error];
        return;
    }
    
    NSMutableArray<NSString *> *TsURIArray = NSMutableArray.array;
    NSMutableArray<NSString *> *URIs = NSMutableArray.array;
    [[content mcs_textCheckingResultsByMatchPattern:MCSURIMatchingPattern_URIs] enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range1 = [obj rangeAtIndex:1];
        NSRange range3 = [obj rangeAtIndex:3];
        if      ( range1.location != NSNotFound ) {
            NSString *TsURI = [content substringWithRange:range1];
            [TsURIArray addObject:TsURI];
            [URIs addObject:TsURI];
        }
        else if ( range3.location != NSNotFound ) {
            NSString *AESKeyURI = [content substringWithRange:range3];
            [URIs addObject:AESKeyURI];
        }
    }];
    
    _TsURIArray = TsURIArray.copy;
    _URIs = URIs.copy;
    
    _isDone = YES;
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate parserParseDidFinish:self];
    });
}
@end

@implementation NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern {
    NSMutableArray<NSValue *> *m = NSMutableArray.array;
    for ( NSTextCheckingResult *result in [self mcs_textCheckingResultsByMatchPattern:pattern])
        [m addObject:[NSValue valueWithRange:result.range]];
    return m.count != 0 ? m.copy : nil;
}

- (nullable NSArray<NSTextCheckingResult *> *)mcs_textCheckingResultsByMatchPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
    NSMutableArray<NSTextCheckingResult *> *m = NSMutableArray.array;
    [regex enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if ( result != nil ) {
            [m addObject:result];
        }
    }];
    return m.count != 0 ? m.copy : nil;
}
@end
