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
    dispatch_barrier_sync(self.queue, ^{
        self->_parser = parser;
        self->_TsCount = parser.TsCount;
        [MCSResourceManager.shared saveMetadata:self];
    });
}

- (MCSHLSParser *)parser {
    __block MCSHLSParser *parser = nil;
    dispatch_sync(self.queue, ^{
        parser = _parser;
    });
    return parser;
}

@synthesize TsContentType = _TsContentType;
- (NSString *)TsContentType {
    __block NSString *TsContentType = nil;
    dispatch_sync(self.queue, ^{
        TsContentType = _TsContentType;
    });
    return TsContentType;
}

- (void)readWriteCountDidChangeForPartialContent:(MCSResourcePartialContent *)content {
    dispatch_barrier_sync(self.queue, ^{
        if ( self.isCacheFinished )
            return;
        if ( content.readWriteCount > 0 )
            return;
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
    });
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
    dispatch_barrier_sync(self.queue, ^{
        self->_TsContentType = TsContentType;
        [MCSResourceManager.shared saveMetadata:self];
    });
}

- (nullable MCSResourcePartialContent *)contentForTsURL:(NSURL *)URL {
    MCSResourcePartialContent *content = nil;
    NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:MCSHLSTsFileExtension];
    for ( MCSResourcePartialContent *c in self.contents ) {
        if ( [c.tsName isEqualToString:TsName] ) {
            NSString *contentPath = [MCSFileManager getFilePathWithName:c.filename inResource:self.name];
            NSUInteger length = [MCSFileManager fileSizeAtPath:contentPath];
            if ( length == c.tsTotalLength ) {
                content = c;
                break;
            }
        }
    }
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

@end
