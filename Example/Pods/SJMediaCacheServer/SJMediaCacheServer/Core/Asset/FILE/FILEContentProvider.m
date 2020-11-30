//
//  FILEContentProvider.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/24.
//

#import "FILEContentProvider.h" 
#import "NSFileManager+MCS.h"

#define FILE_PREFIX_CONTENT @"file"
 
@implementation FILEContentProvider {
    NSString *_directory;
}

+ (instancetype)contentProviderWithDirectory:(NSString *)directory {
    FILEContentProvider *mgr = FILEContentProvider.alloc.init;
    mgr->_directory = directory;
    return mgr;
}

- (nullable NSArray<FILEContent *> *)contents {
    NSMutableArray<FILEContent *> *m = nil;
    for ( NSString *filename in [NSFileManager.defaultManager contentsOfDirectoryAtPath:_directory error:NULL] ) {
        if ( ![filename hasPrefix:FILE_PREFIX_CONTENT] ) continue;
        if ( m == nil ) m = NSMutableArray.array;
        NSString *filePath = [self contentFilePathForFilename:filename];
        NSUInteger offset = [self _offsetForFilename:filename];
        NSUInteger length = (NSUInteger)[NSFileManager.defaultManager mcs_fileSizeAtPath:filePath];
        FILEContent *content = [FILEContent.alloc initWithFilename:filename atOffset:offset length:length];
        [m addObject:content];
    }
    return m.copy;
}

- (nullable FILEContent *)createContentAtOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension {
    if ( ![NSFileManager.defaultManager fileExistsAtPath:_directory] ) {
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:&error];
        if ( error != nil ) return nil;
    }
    
    NSUInteger number = 0;
    do {
        NSString *filename = [self _filenameWithOffset:offset number:number pathExtension:pathExtension];
        NSString *filePath = [self contentFilePathForFilename:filename];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filePath] ) {
            [NSFileManager.defaultManager createFileAtPath:filePath contents:nil attributes:nil];
            return [FILEContent.alloc initWithFilename:filename atOffset:offset];
        }
        number += 1;
    } while (true);
    return nil;
}

- (nullable NSString *)contentFilePathForFilename:(NSString *)filename {
    return filename.length != 0 ? [_directory stringByAppendingPathComponent:filename] : nil;
}

- (void)removeContentForFilename:(NSString *)filename {
    NSString *filePath = [self contentFilePathForFilename:filename];
    [NSFileManager.defaultManager removeItemAtPath:filePath error:NULL];
}

#pragma mark - 前缀_偏移量_序号.扩展名

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
