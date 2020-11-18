//
//  HLSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSAsset.h"
#import "MCSAssetManager.h"
#import "HLSReader.h"
#import "HLSParser.h"
#import "MCSFileManager.h"
#import "MCSQueue.h"

@interface HLSAsset ()
@property (nonatomic) NSUInteger TsCount;
@end

@implementation HLSAsset

- (MCSAssetType)type {
    return MCSAssetTypeHLS;
}

- (id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request {
    return [HLSReader.alloc initWithAsset:self request:request];
}
 
- (NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    return [MCSURLRecognizer.shared proxyURLWithURL:URL];
}

- (void)prepareContents {
    _parser = [HLSParser parserInAssetIfExists:_name];
    [self addContents:[MCSFileManager getContentsInAsset:_name]];
}

@synthesize parser = _parser;
- (void)setParser:(HLSParser *)parser {
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        _parser = parser;
        _TsCount = parser.TsCount;
    });
    [MCSAssetManager.shared saveMetadata:self];
}

- (HLSParser *)parser {
    __block HLSParser *parser = nil;
    dispatch_sync(MCSAssetQueue(), ^{
        parser = _parser;
    });
    return parser;
} 

- (void)readWriteCountDidChangeForPartialContent:(MCSAssetContent *)content {
    if ( content.readWriteCount > 0 )
        return;
    
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        if ( _isCacheFinished )
            return;
        
        if ( _m.count <= 1 )
            return;
        
        NSMutableArray<MCSAssetContent *> *list = NSMutableArray.alloc.init;
        for ( MCSAssetContent *content in _m ) {
            if ( content.readWriteCount == 0 )
                [list addObject:content];
        }
        
        if ( list.count <= 1 )
            return;
        
        NSMutableArray<MCSAssetContent *> *deleteContents = NSMutableArray.alloc.init;
        for ( NSInteger i = 0 ; i < list.count ; ++ i ) {
            MCSAssetContent *obj1 = list[i];
            for ( NSInteger j = i + 1 ; j < list.count ; ++ j ) {
                MCSAssetContent *obj2 = list[j];
                if ( [obj1.tsName isEqualToString:obj2.tsName] ) {
                    [deleteContents addObject:obj1.length >= obj2.length ? obj2 : obj1];
                }
            }
        }
        
        if ( deleteContents.count == 0 )
            return;
         
        for ( MCSAssetContent *content in deleteContents ) {
            [self removeContent:content];
        }
    });
}
 
#pragma mark -

- (NSString *)filePathOfContent:(MCSAssetContent *)content {
    return [MCSFileManager getFilePathWithName:content.filename inAsset:self.name];
}

- (nullable MCSAssetContent *)contentForTsURL:(NSURL *)URL {
    __block MCSAssetContent *content = nil;
    NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:HLSFileExtensionTS];
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        for ( MCSAssetContent *c in _m ) {
            if ( [c.tsName isEqualToString:TsName] ) {
                NSString *contentPath = [MCSFileManager getFilePathWithName:c.filename inAsset:self.name];
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

- (MCSAssetContent *)createContentWithTsURL:(NSURL *)URL totalLength:(NSUInteger)totalLength {
    MCSAssetContent *content = nil;
    NSString *TsName = [MCSURLRecognizer.shared nameWithUrl:URL.absoluteString extension:HLSFileExtensionTS];
    NSString *filename = [MCSFileManager HLS_createContentFileInAsset:self.name tsName:TsName tsTotalLength:totalLength];
    content = [MCSAssetContent.alloc initWithFilename:filename tsName:TsName tsTotalLength:totalLength length:0];
    [self addContent:content];
    return content;
}

- (void)contentsDidChange:(NSArray<MCSAssetContent *> *)contents {
    BOOL isContentsFinished = YES;
    NSUInteger count = 0;
    for ( MCSAssetContent *c in contents ) {
        if ( c.length != c.tsTotalLength ) {
            isContentsFinished = NO;
            break;
        }
        count += 1;
    }
    
    _isCacheFinished = isContentsFinished && count == _TsCount;
}
@end
