//
//  MCSHLSResource.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSHLSResource.h"
#import "MCSResourceManager.h"
#import "MCSHLSReader.h"
#import "MCSHLSParser.h"
#import "MCSFileManager.h" 

@interface MCSHLSResource ()
@property (nonatomic) NSUInteger TsCount;
@end

@implementation MCSHLSResource

- (MCSResourceType)type {
    return MCSResourceTypeHLS;
}

- (id<MCSResourceReader>)readerWithRequest:(NSURLRequest *)request {
    return [MCSHLSReader.alloc initWithResource:self request:request];
}
 
- (void)addContents:(NSArray<MCSResourcePartialContent *> *)contents {
    [super addContents:contents];
    [self _contentsDidChange];
}

- (NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    return [MCSURLRecognizer.shared proxyURLWithURL:URL];
}

@synthesize parser = _parser;
- (void)setParser:(MCSHLSParser *)parser {
    BOOL updated = NO;
    [self lock];
    if ( parser != _parser ) {
        _parser = parser;
        _TsCount = parser.TsCount;
        updated = YES;
    }
    [self unlock];
    if ( updated ) [MCSResourceManager.shared saveMetadata:self];
}

- (MCSHLSParser *)parser {
    [self lock];
    @try {
        return _parser;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize TsContentType = _TsContentType;
- (NSString *)TsContentType {
    [self lock];
    @try {
        return _TsContentType;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)readWriteCountDidChangeForPartialContent:(MCSResourcePartialContent *)content {
    if ( self.isCacheFinished ) return;
    if ( content.readWriteCount > 0 ) return;
    [self lock];
    @try {
        if ( self.contents.count <= 1 )
            return;
        
        NSMutableArray<MCSResourcePartialContent *> *list = NSMutableArray.alloc.init;
        for ( MCSResourcePartialContent *content in self.contents ) {
            if ( content.readWriteCount == 0 )
                [list addObject:content];
        }
        
        if ( list.count <= 1 )
            return;
        
        NSMutableArray<MCSResourcePartialContent *> *deleteContents = NSMutableArray.alloc.init;
        for ( NSInteger i = 0 ; i < list.count ; ++ i ) {
            MCSResourcePartialContent *obj1 = list[i];
            for ( NSInteger j = i + 1 ; j < list.count ; ++ j ) {
                MCSResourcePartialContent *obj2 = list[j];
                if ( [obj1.tsName isEqualToString:obj2.tsName] ) {
                    [deleteContents addObject:obj1.length >= obj2.length ? obj2 : obj1];
                }
                else if ( [obj1.AESKeyName isEqualToString:obj2.AESKeyName] ) {
                    [deleteContents addObject:obj1.length >= obj2.length ? obj2 : obj1];
                }
            }
        }
        
        if ( deleteContents.count == 0 )
            return;
         
        for ( MCSResourcePartialContent *content in deleteContents ) {
            [self removeContent:content];
        }
        
        [self _contentsDidChange];
    } @catch (NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)partialContent:(MCSResourcePartialContent *)content didWriteDataWithLength:(NSUInteger)length {
    [MCSResourceManager.shared didWriteDataForResource:self length:length];
}

- (void)_contentsDidChange {
    NSArray *contents = self.contents.copy;
    
    BOOL isContentsFinished = YES;
    NSUInteger count = 0;
    for ( MCSResourcePartialContent *content in contents ) {
        if ( content.tsName != nil ) {
            if ( content.length != content.tsTotalLength ) {
                isContentsFinished = NO;
                break;
            }
            count += 1;
        }
    }
    
    self.isCacheFinished = isContentsFinished && count == _TsCount;
}

 
#pragma mark -


- (NSString *)filePathOfContent:(MCSResourcePartialContent *)content {
    return [MCSFileManager getFilePathWithName:content.filename inResource:self.name];
}

- (void)updateTsContentType:(NSString * _Nullable)TsContentType {
    [self lock];
    _TsContentType = TsContentType;
    [self unlock];
    [MCSResourceManager.shared saveMetadata:self];
}

- (nullable MCSResourcePartialContent *)contentForTsURL:(NSURL *)URL {
    [self lock];
    @try {
        NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:MCSHLSTsFileExtension];
        for ( MCSResourcePartialContent *content in self.contents ) {
            if ( [content.tsName isEqualToString:TsName] ) {
                NSString *contentPath = [MCSFileManager getFilePathWithName:content.filename inResource:self.name];
                NSUInteger length = [MCSFileManager fileSizeAtPath:contentPath];
                if ( length == content.tsTotalLength )
                    return content;
            }
        }
        return nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}
- (MCSResourcePartialContent *)createContentWithTsURL:(NSURL *)URL totalLength:(NSUInteger)totalLength {
    [self lock];
    @try {
        NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:MCSHLSTsFileExtension];
        NSString *filename = [MCSFileManager hls_createContentFileInResource:self.name tsName:TsName tsTotalLength:totalLength];
        MCSResourcePartialContent *content = [MCSResourcePartialContent.alloc initWithFilename:filename tsName:TsName tsTotalLength:totalLength length:0];
        [self addContent:content];
        return content;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@end
