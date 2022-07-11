//
//  FILEAssetContentProvider.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/24.
//

#import "FILEAssetContentProvider.h" 
#import "NSFileManager+MCS.h"
#import "MCSAssetContent.h"

#define FILE_PREFIX_CONTENT @"file"
 
@implementation FILEAssetContentProvider {
    NSString *_directory;
}

+ (instancetype)contentProviderWithDirectory:(NSString *)directory {
    FILEAssetContentProvider *mgr = FILEAssetContentProvider.alloc.init;
    mgr->_directory = directory;
    return mgr;
}

- (nullable NSArray<id<MCSAssetContent>> *)contents {
    NSMutableArray<id<MCSAssetContent>> *m = nil;
    for ( NSString *filename in [NSFileManager.defaultManager contentsOfDirectoryAtPath:_directory error:NULL] ) {
        if ( ![filename hasPrefix:FILE_PREFIX_CONTENT] ) continue;
        if ( m == nil ) m = NSMutableArray.array;
        NSString *filepath = [self _contentFilepathForFilename:filename];
        NSUInteger offset = [self _offsetForFilename:filename];
        NSUInteger length = (NSUInteger)[NSFileManager.defaultManager mcs_fileSizeAtPath:filepath];
        id<MCSAssetContent>content = [MCSAssetContent.alloc initWithFilepath:filepath startPositionInAsset:offset length:length];
        [m addObject:content];
    }
    return m.copy;
}

- (nullable id<MCSAssetContent>)createContentAtOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension {
    if ( ![NSFileManager.defaultManager fileExistsAtPath:_directory] ) {
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:&error];
        if ( error != nil ) return nil;
    }
    
    NSUInteger number = 0;
    do {
        NSString *filename = [self _filenameWithOffset:offset number:number pathExtension:pathExtension];
        NSString *filepath = [self _contentFilepathForFilename:filename];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
            [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
            return [MCSAssetContent.alloc initWithFilepath:filepath startPositionInAsset:offset];
        }
        number += 1;
    } while (true);
    return nil;
}

- (nullable NSString *)contentFilepath:(MCSAssetContent *)content {
    return content.filepath;
}

- (void)removeContent:(MCSAssetContent *)content {
    [NSFileManager.defaultManager removeItemAtPath:content.filepath error:NULL];
}

#pragma mark - 前缀_偏移量_序号.扩展名

- (nullable NSString *)_contentFilepathForFilename:(NSString *)filename {
    return filename.length != 0 ? [_directory stringByAppendingPathComponent:filename] : nil;
}

- (NSString *)_filenameWithOffset:(NSUInteger)offset number:(NSInteger)number pathExtension:(nullable NSString *)pathExtension {
    // _FILE_NAME(__prefix__, __offset__, __number__, __extension__)
    NSString *filename = [NSString stringWithFormat:@"%@_%ld_%lu", FILE_PREFIX_CONTENT, (unsigned long)offset, (long)number];
    if ( pathExtension.length != 0 ) filename = [filename stringByAppendingPathExtension:pathExtension];
    return filename;
}

- (NSUInteger)_offsetForFilename:(NSString *)filename {
    return (NSUInteger)[[filename componentsSeparatedByString:@"_"][1] longLongValue];
}
@end
