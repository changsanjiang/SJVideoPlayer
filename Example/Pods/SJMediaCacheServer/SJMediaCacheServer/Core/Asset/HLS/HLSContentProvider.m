//
//  HLSContentProvider.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "HLSContentProvider.h"
#import "MCSConsts.h"
#import "NSFileManager+MCS.h"

#define HLS_PREFIX_CONTENT  @"hls"
#define HLS_FILENAME_INDEX  [NSString stringWithFormat:@"index%@", HLS_SUFFIX_INDEX]

@implementation HLSContentProvider {
    NSString *_directory;
}

- (instancetype)initWithDirectory:(NSString *)directory {
    self = [super init];
    if ( self ) {
        _directory = directory;
        if ( ![NSFileManager.defaultManager fileExistsAtPath:_directory] ) {
            [NSFileManager.defaultManager createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    return self;
}

- (NSString *)indexFilePath {
    return [_directory stringByAppendingPathComponent:HLS_FILENAME_INDEX];
}

- (NSString *)AESKeyFilePathWithName:(NSString *)AESKeyName {
    return [_directory stringByAppendingPathComponent:AESKeyName];
}

- (nullable NSArray<HLSContentTs *> *)TsContents {
    NSMutableArray<HLSContentTs *> *m = nil;
    for ( NSString *filename in [NSFileManager.defaultManager contentsOfDirectoryAtPath:_directory error:NULL] ) {
        if ( ![filename hasPrefix:HLS_PREFIX_CONTENT] ) continue;
        if ( m == nil ) m = NSMutableArray.array;
        NSString *filePath = [self TsContentFilePathForFilename:filename];
        NSString *name = [self _TsNameForFilename:filename];
        long long totalLength = [self _TsTotalLengthForFilename:filename];
        long long length = (long long)[NSFileManager.defaultManager mcs_fileSizeAtPath:filePath];
        HLSContentTs *ts = [HLSContentTs.alloc initWithName:name filename:filename totalLength:totalLength length:length];
        [m addObject:ts];
    }
    return m;
}

- (nullable HLSContentTs *)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength {
    NSUInteger number = 0;
    do {
        NSString *filename = [self _TsFilenameWithName:name totalLength:totalLength number:number];
        NSString *filePath = [self TsContentFilePathForFilename:filename];
        NSString *name = [self _TsNameForFilename:filename];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filePath] ) {
            [NSFileManager.defaultManager createFileAtPath:filePath contents:nil attributes:nil];
            return [HLSContentTs.alloc initWithName:name filename:filename totalLength:totalLength];
        }
        number += 1;
    } while (true);
    return nil;
}

- (nullable NSString *)TsContentFilePathForFilename:(NSString *)filename {
    return [_directory stringByAppendingPathComponent:filename];
}

- (void)removeTsContentForFilename:(NSString *)filename {
    NSString *filePath = [self TsContentFilePathForFilename:filename];
    [NSFileManager.defaultManager removeItemAtPath:filePath error:NULL];
}

#pragma mark - mark

- (NSString *)_TsFilenameWithName:(NSString *)name totalLength:(long long)totalLength number:(NSInteger)number {
    // _FILE_NAME(__prefix__, __totalLength__, __number__, __TsName__)
    return [NSString stringWithFormat:@"%@_%lld_%ld_%@", HLS_PREFIX_CONTENT, totalLength, (long)number, name];
}

- (long long)_TsTotalLengthForFilename:(NSString *)filename {
    return [[filename componentsSeparatedByString:@"_"][1] longLongValue];;
}

- (NSString *)_TsNameForFilename:(NSString *)filename {
    return [filename componentsSeparatedByString:@"_"].lastObject;
}
@end
