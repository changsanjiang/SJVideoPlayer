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
#import "MCSQueue.h"

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
 
- (NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    return [MCSURLRecognizer.shared proxyURLWithURL:URL];
}

@synthesize parser = _parser;
- (void)setParser:(MCSHLSParser *)parser {
    dispatch_barrier_sync(MCSResourceQueue(), ^{
        _parser = parser;
        _TsCount = parser.TsCount;
    });
    [MCSResourceManager.shared saveMetadata:self];
}

- (MCSHLSParser *)parser {
    __block MCSHLSParser *parser = nil;
    dispatch_sync(MCSResourceQueue(), ^{
        parser = _parser;
    });
    return parser;
}

@synthesize TsContentType = _TsContentType;
- (NSString *)TsContentType {
    __block NSString *TsContentType = nil;
    dispatch_sync(MCSResourceQueue(), ^{
        TsContentType = _TsContentType;
    });
    return TsContentType;
}

- (void)readWriteCountDidChangeForPartialContent:(MCSResourcePartialContent *)content {
    if ( content.readWriteCount > 0 )
        return;
    
    dispatch_barrier_sync(MCSResourceQueue(), ^{
        if ( _isCacheFinished )
            return;
        
        if ( _m.count <= 1 )
            return;
        
        NSMutableArray<MCSResourcePartialContent *> *list = NSMutableArray.alloc.init;
        for ( MCSResourcePartialContent *content in _m ) {
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
            }
        }
        
        if ( deleteContents.count == 0 )
            return;
         
        for ( MCSResourcePartialContent *content in deleteContents ) {
            [self removeContent:content];
        }
    });
}
 
#pragma mark -

- (NSString *)filePathOfContent:(MCSResourcePartialContent *)content {
    return [MCSFileManager getFilePathWithName:content.filename inResource:self.name];
}

- (void)updateTsContentType:(NSString * _Nullable)TsContentType {
    dispatch_barrier_sync(MCSResourceQueue(), ^{
        _TsContentType = TsContentType;
        [MCSResourceManager.shared saveMetadata:self];
    });
}

- (nullable MCSResourcePartialContent *)contentForTsURL:(NSURL *)URL {
    __block MCSResourcePartialContent *content = nil;
    NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:MCSHLSTsFileExtension];
    dispatch_barrier_sync(MCSResourceQueue(), ^{
        for ( MCSResourcePartialContent *c in _m ) {
            if ( [c.tsName isEqualToString:TsName] ) {
                NSString *contentPath = [MCSFileManager getFilePathWithName:c.filename inResource:self.name];
                NSUInteger length = [MCSFileManager fileSizeAtPath:contentPath];
                if ( length == c.tsTotalLength ) {
                    content = c;
                    break;
                }
            }
        }
    });
    return content;
}

- (MCSResourcePartialContent *)createContentWithTsURL:(NSURL *)URL totalLength:(NSUInteger)totalLength {
    MCSResourcePartialContent *content = nil;
    NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:MCSHLSTsFileExtension];
    NSString *filename = [MCSFileManager hls_createContentFileInResource:self.name tsName:TsName tsTotalLength:totalLength];
    content = [MCSResourcePartialContent.alloc initWithFilename:filename tsName:TsName tsTotalLength:totalLength length:0];
    [self addContent:content];
    return content;
}

- (void)contentsDidChange:(NSArray<MCSResourcePartialContent *> *)contents {
    BOOL isContentsFinished = YES;
    NSUInteger count = 0;
    for ( MCSResourcePartialContent *c in contents ) {
        if ( c.length != c.tsTotalLength ) {
            isContentsFinished = NO;
            break;
        }
        count += 1;
    }
    
    _isCacheFinished = isContentsFinished && count == _TsCount;
}
@end
