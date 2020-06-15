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

@interface NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern;
@end

@interface MCSHLSParser ()<NSLocking> {
    NSRecursiveLock *_lock;
}
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, strong, nullable) NSURL *URL;
@property (nonatomic, weak, nullable) id<MCSHLSParserDelegate> delegate;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *tsFragments;
@property (nonatomic, strong, nullable) NSArray<NSString *> *tsNames;
@end

@implementation MCSHLSParser
- (instancetype)initWithURL:(NSURL *)URL inResource:(NSString *)resource delegate:(id<MCSHLSParserDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _resourceName = resource;
        _URL = URL;
        _delegate = delegate;
        _lock = NSRecursiveLock.alloc.init;
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
    return [MCSFileManager hls_indexFilePathInResource:self.resourceName];
}

#pragma mark -

- (void)_parse {
    if ( self.isClosed )
        return;
    
    NSString *indexFilePath = self.indexFilePath;
    NSString *tsNameFilePath = [MCSFileManager hls_tsNamesFilePathInResource:_resourceName];
    NSString *tsFragmentsFilePath = [MCSFileManager hls_tsFragmentsFilePathInResource:_resourceName];
    // 已解析过, 将直接读取本地
    if ( [MCSFileManager fileExistsAtPath:indexFilePath] &&
         [MCSFileManager fileExistsAtPath:tsNameFilePath] &&
         [MCSFileManager fileExistsAtPath:tsFragmentsFilePath] ) {
        [self lock];
        _tsFragments = [NSDictionary dictionaryWithContentsOfFile:tsFragmentsFilePath];
        _tsNames = [NSArray arrayWithContentsOfFile:tsNameFilePath];
        _isDone = YES;
        [self unlock];
        [self.delegate parserParseDidFinish:self];
        return;
    }
    
    NSString *url = _URL.absoluteString;
    NSString *_Nullable contents = nil;
    __block NSError *_Nullable error = nil;
    do {
        NSURL *URL = [NSURL URLWithString:url];
        contents = [NSString stringWithContentsOfURL:URL encoding:0 error:&error];
        if ( contents == nil )
            break;

        // 是否重定向
        url = [self _urlsWithPattern:@"(?:.*\\.m3u8[^\\s]*)" url:url source:contents].firstObject;
    } while ( url != nil );

    if ( error != nil || contents == nil || ![contents hasPrefix:@"#"] ) {
        [self _onError:error ?: [NSError mcs_errorForHLSFileParseError:_URL]];
        return;
    }
 
    NSMutableString *indexFileContents = contents.mutableCopy;
    NSMutableDictionary<NSString *, NSString *> *tsFragments = NSMutableDictionary.dictionary;
    NSMutableArray<NSString *> *reversedTsNames = NSMutableArray.array;
    [[contents mcs_rangesByMatchingPattern:@"(?:.*\\.ts[^\\s]*)"] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [[indexFileContents mcs_rangesByMatchingPattern:@"#EXT-X-KEY:METHOD=AES-128,URI=\".*\""] enumerateObjectsUsingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangeValue = range.rangeValue;
        NSString *matched = [contents substringWithRange:rangeValue];
        NSInteger URILocation = [matched rangeOfString:@"\""].location + 1;
        NSRange URIRange = NSMakeRange(URILocation, matched.length-URILocation-1);
        NSString *URI = [matched substringWithRange:URIRange];
        NSData *keyData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URI] options:0 error:&error];
        if ( error != nil ) {
            *stop = YES;
            return ;
        }
        NSString *filename = [MCSFileManager hls_AESKeyFilenameForURI:URI];
        NSString *filepath = [MCSFileManager getFilePathWithName:filename inResource:self.resourceName];
        [keyData writeToFile:filepath options:0 error:&error];
        if ( error != nil ) {
            *stop = YES;
            return ;
        }
        NSString *reset = [matched stringByReplacingCharactersInRange:URIRange withString:filename];
        [indexFileContents replaceCharactersInRange:rangeValue withString:reset];
    }];

    if ( error != nil ) {
        [self _onError:error];
        return;
    }
    
    if ( tsFragments.count == 0 ) {
        [self _onError:[NSError mcs_errorForHLSFileParseError:_URL]];
        return;
    }
    
    if ( ![tsFragments writeToFile:tsFragmentsFilePath atomically:YES] ) {
        [self _onError:[NSError mcs_errorForHLSFileParseError:_URL]];
        return;
    }
    NSArray<NSString *> *tsNames = [[reversedTsNames reverseObjectEnumerator] allObjects];
    if ( ![tsNames writeToFile:tsNameFilePath atomically:YES] ) {
        [self _onError:[NSError mcs_errorForHLSFileParseError:_URL]];
        return;
    }
    
    if ( ![indexFileContents writeToFile:indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
        [self _onError:error];
        return;
    }
    
    [self lock];
    _tsNames = tsNames;
    _tsFragments = tsFragments;
    _isDone = YES;
    [self unlock];
    [self.delegate parserParseDidFinish:self];
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
        error = [NSError mcs_errorForHLSFileParseError:_URL];
    }
    [self.delegate parser:self anErrorOccurred:error];
}

- (void)lock {
    [_lock lock];
}

- (void)unlock {
    [_lock unlock];
}
@end

@implementation NSString (MCSRegexMatching)
- (nullable NSArray<NSValue *> *)mcs_rangesByMatchingPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
    NSMutableArray<NSValue *> *m = NSMutableArray.array;
    [regex enumerateMatchesInString:self options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if ( result != nil ) {
            [m addObject:[NSValue valueWithRange:result.range]];
        }
    }];
    return m.count != 0 ? m.copy : nil;
}
@end
