//
//  MCSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEAsset.h"
#import "MCSAssetDefines.h"
#import "FILEReader.h"
#import "MCSAssetManager.h"
#import "MCSFileManager.h"
#import "MCSUtils.h"
#import "MCSAssetSubclass.h"
#import "MCSQueue.h"

@interface FILEAsset () {
    NSURL *_playbackURLForCache;
}
@property (nonatomic) NSUInteger totalLength;
@property (nonatomic, copy, nullable) NSString *pathExtension;
@end

@implementation FILEAsset

- (MCSAssetType)type {
    return MCSAssetTypeFILE;
}

- (id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request {
    return [FILEReader.alloc initWithAsset:self request:request];
}

- (NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    __block NSURL *playbackURLForCache = nil;
    dispatch_sync(MCSAssetQueue(), ^{
        playbackURLForCache = _playbackURLForCache;
    });
    return playbackURLForCache;
}

- (void)prepareContents {
    [self addContents:[MCSFileManager getContentsInAsset:_name]];
}

#pragma mark -

- (MCSAssetContent *)createContentWithOffset:(NSUInteger)offset response:(NSHTTPURLResponse *)response {
    __block BOOL isUpdated = NO;
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        if ( _pathExtension == nil || _totalLength == 0 ) {
            _pathExtension = MCSSuggestedFilePathExtension(response);
            _totalLength = MCSGetResponseContentRange(response).totalLength;
            isUpdated = YES;
        }
    });
    if ( isUpdated ) [MCSAssetManager.shared saveMetadata:self];
    NSString *filename = [MCSFileManager FILE_createContentFileInAsset:self.name atOffset:offset pathExtension:self.pathExtension];
    MCSAssetContent *content = [MCSAssetContent.alloc initWithFilename:filename offset:offset];
    [self addContent:content];
    return content;
}
 
- (NSUInteger)totalLength {
    __block NSUInteger totalLength = 0;
    dispatch_sync(MCSAssetQueue(), ^{
        totalLength = _totalLength;
    });
    return totalLength;
}
 
- (void)readWriteCountDidChangeForPartialContent:(MCSAssetContent *)content {
    if ( content.readWriteCount > 0 )
        return;
    
    dispatch_barrier_sync(MCSAssetQueue(), ^{
        if ( _isCacheFinished )
            return;
        
        if ( _m.count <= 1 )
            return;
        
        @try {
            // 合并文件
            NSMutableArray<MCSAssetContent *> *list = NSMutableArray.alloc.init;
            for ( MCSAssetContent *content in _m ) {
                if ( content.readWriteCount == 0 )
                    [list addObject:content];
            }
            
            NSMutableArray<MCSAssetContent *> *deleteContents = NSMutableArray.alloc.init;
            [list sortUsingComparator:^NSComparisonResult(MCSAssetContent *obj1, MCSAssetContent *obj2) {
                NSRange range1 = NSMakeRange(obj1.offset, obj1.length);
                NSRange range2 = NSMakeRange(obj2.offset, obj2.length);
                
                // 1 包含 2
                if ( MCSNSRangeContains(range1, range2) ) {
                    if ( ![deleteContents containsObject:obj2] ) [deleteContents addObject:obj2];
                }
                // 2 包含 1
                else if ( MCSNSRangeContains(range2, range1) ) {
                    if ( ![deleteContents containsObject:obj1] ) [deleteContents addObject:obj1];;
                }
                
                return range1.location < range2.location ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            if ( deleteContents.count != 0 ) [list removeObjectsInArray:deleteContents];

            for ( NSInteger i = 0 ; i < list.count - 1; i += 2 ) {
                MCSAssetContent *write = list[i];
                MCSAssetContent *read  = list[i + 1];
                NSRange readRange = NSMakeRange(0, 0);

                NSUInteger maxA = write.offset + write.length;
                NSUInteger maxR = read.offset + read.length;
                if ( maxA >= read.offset && maxA < maxR ) // 有交集
                    readRange = NSMakeRange(maxA - read.offset, maxR - maxA); // 读取read中未相交的部分

                if ( readRange.length != 0 ) {
                    NSFileHandle *writer = [NSFileHandle fileHandleForWritingAtPath:[self filePathOfContent:write]];
                    NSFileHandle *reader = [NSFileHandle fileHandleForReadingAtPath:[self filePathOfContent:read]];
                    @try {
                        [writer seekToEndOfFile];
                        [reader seekToFileOffset:readRange.location];
                        while (true) {
                            @autoreleasepool {
                                NSData *data = [reader readDataOfLength:1024 * 1024 * 1];
                                if ( data.length == 0 )
                                    break;
                                [writer writeData:data];
                            }
                        }
                        [reader closeFile];
                        [writer synchronizeFile];
                        [writer closeFile];
                        [write didWriteDataWithLength:readRange.length];
                        [deleteContents addObject:read];
                    } @catch (NSException *exception) {
                        break;
                    }
                }
            }
            
            for ( MCSAssetContent *content in deleteContents ) {
                [self removeContent:content];
            }
            
        } @catch (__unused NSException *exception) {
            
        }
    });
}

- (void)contentsDidChange:(NSArray<MCSAssetContent *> *)contents {
    if ( _isCacheFinished )
        return;
    if ( _totalLength == 0 )
        return;
    if ( contents.count > 1 )
        return;
    
    MCSAssetContent *result = contents.lastObject;
    _isCacheFinished = result.length == _totalLength;
    if ( _isCacheFinished ) {
        NSString *resultPath = [self filePathOfContent:result];
        _playbackURLForCache = [NSURL fileURLWithPath:resultPath];
    }
}
@end
