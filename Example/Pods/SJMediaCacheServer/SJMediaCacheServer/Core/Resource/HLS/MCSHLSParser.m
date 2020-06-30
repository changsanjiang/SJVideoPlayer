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
#import "MCSDownload.h"

@interface MCSData : NSObject<MCSDownloadTaskDelegate>
+ (NSData *)dataWithContentsOfURL:(NSURL *)url error:(NSError **)error;
@end

@implementation MCSData {
    dispatch_semaphore_t _semaphore;
    NSMutableData *_m;
    NSError *_error;
}

+ (nullable NSData *)dataWithContentsOfURL:(NSURL *)url error:(NSError **)error {
    MCSData *data = [MCSData.alloc initWithContentsOfURL:url error:error];
    return data != nil ? data->_m : nil;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)error {
    self = [super init];
    if ( self ) {
        _m = NSMutableData.data;
        _semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [MCSDownload.shared downloadWithRequest:request priority:1 delegate:self];
        });
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        if ( _error != nil && error != NULL ) *error = _error;
    }
    return self;
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response { }

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    [_m appendData:data];
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    _error = error;
    dispatch_semaphore_signal(_semaphore);
}
@end

@interface NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern;
- (nullable NSArray<NSTextCheckingResult *> *)mcs_textCheckingResultsByMatchPattern:(NSString *)pattern;
@end

@interface MCSHLSParser ()<NSLocking> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, strong, nullable) NSURL *URL;
@property (nonatomic, weak, nullable) id<MCSHLSParserDelegate> delegate;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *tsFragments;
@property (nonatomic, strong, nullable) NSArray<NSString *> *tsNames;
@property (nonatomic) dispatch_queue_t delegateQueue;
@end

@implementation MCSHLSParser
- (instancetype)initWithURL:(NSURL *)URL inResource:(NSString *)resource delegate:(id<MCSHLSParserDelegate>)delegate delegateQueue:(dispatch_queue_t)queue {
    self = [super init];
    if ( self ) {
        _resourceName = resource;
        _URL = URL;
        _delegate = delegate;
        _delegateQueue = queue;
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSURL *)tsURLWithTsName:(NSString *)tsName {
    [self lock];
    @try {
        return [NSURL URLWithString:_tsFragments[tsName]];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSString *)tsNameAtIndex:(NSUInteger)index {
    [self lock];
    @try {
        return index < _tsNames.count ? _tsNames[index] : nil;
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

- (NSUInteger)tsCount {
    [self lock];
    @try {
        return _tsNames.count;
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
    NSString *tsNameFilePath = [MCSFileManager hls_tsNamesFilePathInResource:_resourceName];
    NSString *tsFragmentsFilePath = [MCSFileManager hls_tsFragmentsFilePathInResource:_resourceName];
    // 已解析过, 将直接读取本地
    if ( [MCSFileManager fileExistsAtPath:indexFilePath] &&
         [MCSFileManager fileExistsAtPath:tsNameFilePath] &&
         [MCSFileManager fileExistsAtPath:tsFragmentsFilePath] ) {
        _tsFragments = [NSDictionary dictionaryWithContentsOfFile:tsFragmentsFilePath];
        _tsNames = [NSArray arrayWithContentsOfFile:tsNameFilePath];
        _isDone = YES;
        
        dispatch_async(_delegateQueue, ^{
            [self.delegate parserParseDidFinish:self];
        });
        return;
    }
    
    NSString *url = _URL.absoluteString;
    NSString *_Nullable contents = nil;
    __block NSError *_Nullable error = nil;
    do {
        NSURL *URL = [NSURL URLWithString:url];
        NSData *data = [MCSData dataWithContentsOfURL:URL error:&error];
        contents = [NSString.alloc initWithData:data encoding:0];
        if ( contents == nil )
            break;

        // 是否重定向
        url = [self _urlsWithPattern:@".*\\.m3u8[^\\s]*" url:url source:contents].firstObject;
    } while ( url != nil );

    if ( error != nil || contents == nil || ![contents hasPrefix:@"#"] ) {
        [self _onError:error ?: [NSError mcs_HLSFileParseError:_URL]];
        return;
    }
 
    NSMutableString *indexFileContents = contents.mutableCopy;
    NSMutableDictionary<NSString *, NSString *> *tsFragments = NSMutableDictionary.dictionary;
    NSMutableArray<NSString *> *reversedTsNames = NSMutableArray.array;
    [[contents mcs_rangesByMatchingPattern:@".*\\.ts[^\\s]*"] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangeValue = range.rangeValue;
        NSString *matched = [contents substringWithRange:rangeValue];
        NSString *url = [self _urlWithMatchedString:matched];
        NSString *tsName = [MCSFileManager hls_tsNameForUrl:url inResource:self.resourceName];
        tsFragments[tsName] = url;
        [reversedTsNames addObject:tsName];
        if ( tsName != nil ) [indexFileContents replaceCharactersInRange:rangeValue withString:tsName];
    }];
 
    ///
    /// #EXT-X-KEY:METHOD=AES-128,URI="...",IV=...
    ///
    [[indexFileContents mcs_textCheckingResultsByMatchPattern:@"#EXT-X-KEY:METHOD=AES-128,URI=\"(.*)\""] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange URIRange = [result rangeAtIndex:1];
        NSString *URI = [indexFileContents substringWithRange:URIRange];
        NSString *url = [self _urlWithMatchedString:URI];
        NSData *keyData = [MCSData dataWithContentsOfURL:[NSURL URLWithString:url] error:&error];
        if ( error != nil ) {
            *stop = YES;
            return ;
        }
        NSString *filename = [MCSFileManager hls_AESKeyFilenameAtIndex:idx inResource:self.resourceName];
        NSString *filepath = [MCSFileManager getFilePathWithName:filename inResource:self.resourceName];
        [keyData writeToFile:filepath options:0 error:&error];
        if ( error != nil ) {
            *stop = YES;
            return ;
        }
        [indexFileContents replaceCharactersInRange:URIRange withString:filename];
    }];

    if ( error != nil ) {
        [self _onError:error];
        return;
    }
    
    if ( tsFragments.count == 0 ) {
        [self _onError:[NSError mcs_HLSFileParseError:_URL]];
        return;
    }
    
    if ( ![tsFragments writeToFile:tsFragmentsFilePath atomically:YES] ) {
        [self _onError:[NSError mcs_HLSFileParseError:_URL]];
        return;
    }
    NSArray<NSString *> *tsNames = [[reversedTsNames reverseObjectEnumerator] allObjects];
    if ( ![tsNames writeToFile:tsNameFilePath atomically:YES] ) {
        [self _onError:[NSError mcs_HLSFileParseError:_URL]];
        return;
    }
    
    if ( ![indexFileContents writeToFile:indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
        [self _onError:error];
        return;
    }
    
    _tsNames = tsNames;
    _tsFragments = tsFragments;
    _isDone = YES;

    dispatch_async(_delegateQueue, ^{
        [self.delegate parserParseDidFinish:self];
    });
}

- (nullable NSArray<NSString *> *)_urlsWithPattern:(NSString *)pattern url:(NSString *)url source:(NSString *)source {
    NSMutableArray<NSString *> *m = NSMutableArray.array;
    [[source mcs_rangesByMatchingPattern:pattern] enumerateObjectsUsingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *matched = [source substringWithRange:[range rangeValue]];
        NSString *matchedUrl = [self _urlWithMatchedString:matched];
        [m addObject:matchedUrl];
    }];
    
    return m.count != 0 ? m.copy : nil;
}

- (NSString *)_urlWithMatchedString:(NSString *)matched {
    NSString *url = nil;
    if ( [matched containsString:@"://"] ) {
        url = matched;
    }
    else if ( [matched hasPrefix:@"/"] ) {
        url = [NSString stringWithFormat:@"%@://%@%@", _URL.scheme, _URL.host, matched];
    }
    else {
        url = [NSString stringWithFormat:@"%@/%@", _URL.absoluteString.stringByDeletingLastPathComponent, matched];
    }
    return url;
}

- (void)_onError:(NSError *)error {
    if ( error.code != MCSHLSFileParseError ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
        error = [NSError mcs_HLSFileParseError:_URL];
    }
    
    dispatch_async(_delegateQueue, ^{
        [self.delegate parser:self anErrorOccurred:error];
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
