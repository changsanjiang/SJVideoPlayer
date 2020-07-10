//
//  MCSHLSParser.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSParser.h"
#import "MCSError.h"
#import "MCSFileManager.h"
#import "MCSData.h"
#import "MCSURLRecognizer.h"
#import "NSURLRequest+MCS.h"

#define MCSURIMatchingPattern_Index     @".*\\.m3u8[^\\s]*"
#define MCSURIMatchingPattern_Ts        @".*\\.ts[^\\s]*"
#define MCSURIMatchingPattern_AESKey    @"#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\""
#define MCSURIMatchingPattern_URIs      @"(.*\\.ts[^\\s]*)|(#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\")"

@interface NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern;
- (nullable NSArray<NSTextCheckingResult *> *)mcs_textCheckingResultsByMatchPattern:(NSString *)pattern;
@end

@interface MCSHLSParser ()<NSLocking> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, weak, nullable) id<MCSHLSParserDelegate> delegate;
@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) NSArray<NSString *> *TsURIArray;
@property (nonatomic) float networkTaskPriority;
@property (nonatomic, strong) NSArray<NSString *> *URIs;
@end

@implementation MCSHLSParser
- (instancetype)initWithResource:(NSString *)resourceName request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSHLSParserDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = networkTaskPriority;
        _resourceName = resourceName;
        _request = request;
        _delegate = delegate;
        _delegateQueue = queue;
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (nullable NSString *)URIAtIndex:(NSUInteger)index {
    [self lock];
    @try {
        return index < _URIs.count ? _URIs[index] : nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)prepare {
    [self lock];
    @try {
        if ( _isClosed || _isCalledPrepare )
            return;
        
        _isCalledPrepare = YES;
        
        @autoreleasepool {
            [self _parse];
        }
    } @catch (__unused NSException *exception) {

    } @finally {
        [self unlock];
    }
}

- (void)close {
    [self lock];
    @try {
        if ( _isClosed )
            return;
        
        _isClosed = YES;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize isDone = _isDone;
- (BOOL)isDone {
    [self lock];
    @try {
        return _isDone;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize isClosed = _isClosed;
- (BOOL)isClosed {
    [self lock];
    @try {
        return _isClosed;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSUInteger)TsCount {
    [self lock];
    @try {
        return _TsURIArray.count;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSString *)indexFilePath {
    return [MCSFileManager hls_indexFilePathInResource:_resourceName];
}

#pragma mark -

- (void)_parse {
    
    NSString *indexFilePath = [MCSFileManager hls_indexFilePathInResource:_resourceName];
    // 已解析过, 将直接读取本地
    if ( [MCSFileManager fileExistsAtPath:indexFilePath] ) {
        [self _finished];
        return;
    }
    
    NSURLRequest *request = _request;
    NSString *_Nullable contents = nil;
    __block NSError *_Nullable error = nil;
    do {
        NSData *data = [MCSData dataWithContentsOfRequest:request networkTaskPriority:_networkTaskPriority error:&error];
        if ( _isClosed ) return;
        contents = [NSString.alloc initWithData:data encoding:0];
        if ( contents == nil )
            break;

        // 是否重定向
        NSString *redirectUrl = [self _urlsWithPattern:MCSURIMatchingPattern_Index indexURL:request.URL source:contents].firstObject;
        if ( redirectUrl == nil ) break;
        
        request = [request mcs_requestWithRedirectURL:[NSURL URLWithString:redirectUrl]];
    } while ( true );

    if ( error != nil || contents == nil || ![contents hasPrefix:@"#"] ) {
        [self _onError:error ?: [NSError mcs_HLSFileParseError:_request.URL]];
        return;
    }
 
    NSMutableString *indexFileContents = contents.mutableCopy;
    ///
    /// 000000.ts
    ///
    NSArray<NSValue *> *TsURIRanges = [contents mcs_rangesByMatchingPattern:MCSURIMatchingPattern_Ts];
    if ( TsURIRanges.count == 0 ) {
        [self _onError:[NSError mcs_HLSFileParseError:_request.URL]];
        return;
    }
    [TsURIRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangeValue = range.rangeValue;
        NSString *matched = [contents substringWithRange:rangeValue];
        NSString *url = [self _urlWithMatchedString:matched indexURL:request.URL];
        NSString *proxy = [MCSURLRecognizer.shared proxyTsURIWithUrl:url inResource:self.resourceName];
        [indexFileContents replaceCharactersInRange:rangeValue withString:proxy];
    }];
 
    ///
    /// #EXT-X-KEY:METHOD=AES-128,URI="...",IV=...
    ///
    [[indexFileContents mcs_textCheckingResultsByMatchPattern:@"#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\""] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange URIRange = [result rangeAtIndex:1];
        NSString *URI = [indexFileContents substringWithRange:URIRange];
        NSString *url = [self _urlWithMatchedString:URI indexURL:request.URL];
        NSString *proxy = [MCSURLRecognizer.shared proxyAESKeyURIWithUrl:url inResource:self.resourceName];
        [indexFileContents replaceCharactersInRange:URIRange withString:proxy];
    }];
    
    [MCSFileManager lock];
    if ( ![MCSFileManager fileExistsAtPath:indexFilePath] ) {
        if ( ![indexFileContents writeToFile:indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
            [MCSFileManager unlock];
            [self _onError:error];
            return;
        }
    }
    [MCSFileManager unlock];
    
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
    if ( error.code != MCSHLSFileParseError ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
        error = [NSError mcs_HLSFileParseError:_request.URL];
    }
    
    dispatch_async(_delegateQueue, ^{
        [self.delegate parser:self anErrorOccurred:error];
    });
}

- (void)_finished {
    if ( _isClosed )
        return;
    
    NSString *indexFilePath = [MCSFileManager hls_indexFilePathInResource:_resourceName];
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
    
    dispatch_async(_delegateQueue, ^{
        [self.delegate parserParseDidFinish:self];
    });
}

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
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
