//
//  HLSAssetContentProvider.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "HLSAssetContentProvider.h"
#import "MCSConsts.h"
#import "NSFileManager+MCS.h"
#import "HLSAssetTsContent.h"

#define HLS_PREFIX_FILENAME   @"hls"
#define HLS_PREFIX_FILENAME1  HLS_PREFIX_FILENAME
#define HLS_PREFIX_FILENAME2 @"hlsr"

@implementation HLSAssetContentProvider {
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

- (NSString *)indexFilepath {
    return [_directory stringByAppendingPathComponent:self.indexFileRelativePath];
}

- (NSString *)indexFileRelativePath {
    return [NSString stringWithFormat:@"index%@", HLS_SUFFIX_INDEX];
}

- (NSString *)AESKeyFilepathWithName:(NSString *)AESKeyName {
    return [_directory stringByAppendingPathComponent:AESKeyName];
}

- (nullable NSArray<id<HLSAssetTsContent>> *)TsContents {
    NSMutableArray<id<HLSAssetTsContent>> *m = nil;
    for ( NSString *filename in [NSFileManager.defaultManager contentsOfDirectoryAtPath:_directory error:NULL] ) {
        if ( ![filename hasPrefix:HLS_PREFIX_FILENAME] )
            continue;
        if ( m == nil )
            m = NSMutableArray.array;
        NSString *filepath = [self _TsContentFilepathForFilename:filename];
        NSString *name = [self _TsNameForFilename:filename];
        id<HLSAssetTsContent>ts = nil;
        long long totalLength = [self _TsTotalLengthForFilename:filename];
        if      ( [filename hasPrefix:HLS_PREFIX_FILENAME2] ) {
            long long length = (long long)[NSFileManager.defaultManager mcs_fileSizeAtPath:filepath];
            NSRange range = [self _TsRangeForFilename:filename];
            ts = [HLSAssetTsContent.alloc initWithName:name filepath:filepath totalLength:totalLength length:length rangeInAsset:range];
        }
        else if ( [filename hasPrefix:HLS_PREFIX_FILENAME1] ) {
            long long length = (long long)[NSFileManager.defaultManager mcs_fileSizeAtPath:filepath];
            ts = [HLSAssetTsContent.alloc initWithName:name filepath:filepath totalLength:totalLength length:length];
        }
        
        if ( ts != nil )
            [m addObject:ts];
    }
    return m;
}

- (nullable id<HLSAssetTsContent>)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength {
    NSUInteger number = 0;
    do {
        NSString *filename = [self _TsFilenameWithName:name totalLength:totalLength number:number];
        NSString *filepath = [self _TsContentFilepathForFilename:filename];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
            [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
            return [HLSAssetTsContent.alloc initWithName:name filepath:filepath totalLength:totalLength];
        }
        number += 1;
    } while (true);
    return nil;
}

/// #EXTINF:3.951478,
/// #EXT-X-BYTERANGE:1544984@1007868
///
/// range
- (nullable id<HLSAssetTsContent>)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength rangeInAsset:(NSRange)range {
    NSUInteger number = 0;
    do {
        NSString *filename = [self _TsFilenameWithName:name totalLength:totalLength rangeInAsset:range number:number];
        NSString *filepath = [self _TsContentFilepathForFilename:filename];
        if ( ![NSFileManager.defaultManager fileExistsAtPath:filepath] ) {
            [NSFileManager.defaultManager createFileAtPath:filepath contents:nil attributes:nil];
            return [HLSAssetTsContent.alloc initWithName:name filepath:filepath totalLength:totalLength rangeInAsset:range];
        }
        number += 1;
    } while (true);
    return nil;
}

- (nullable NSString *)TsContentFilepath:(HLSAssetTsContent *)content {
    return content.filepath;
}

- (void)removeTsContent:(HLSAssetTsContent *)content {
    [NSFileManager.defaultManager removeItemAtPath:content.filepath error:NULL];
}

#pragma mark - mark

- (NSString *)_TsFilenameWithName:(NSString *)name totalLength:(long long)totalLength number:(NSInteger)number {
    // _FILE_NAME1(__prefix__, __totalLength__, __number__, __TsName__)
    return [NSString stringWithFormat:@"%@_%lld_%ld_%@", HLS_PREFIX_FILENAME1, totalLength, (long)number, name];
}

- (NSString *)_TsFilenameWithName:(NSString *)name totalLength:(NSUInteger)totalLength rangeInAsset:(NSRange)range number:(NSInteger)number {
    // _FILE_NAME2(__prefix__, __totalLength__, __offset__, __number__, __TsName__)
    return [NSString stringWithFormat:@"%@_%lu_%lu_%lu_%ld_%@", HLS_PREFIX_FILENAME2, (unsigned long)totalLength, (unsigned long)range.location, (unsigned long)range.length, (long)number, name];
}

#pragma mark -

- (nullable NSString *)_TsContentFilepathForFilename:(NSString *)filename {
    return [_directory stringByAppendingPathComponent:filename];
}

- (NSString *)_TsNameForFilename:(NSString *)filename {
    return [filename componentsSeparatedByString:@"_"].lastObject;
}

- (long long)_TsTotalLengthForFilename:(NSString *)filename {
    return [[filename componentsSeparatedByString:@"_"][1] longLongValue];;
}

- (NSRange)_TsRangeForFilename:(NSString *)filename {
    NSArray<NSString *> *contents = [filename componentsSeparatedByString:@"_"];
    return NSMakeRange(contents[2].longLongValue, contents[3].longLongValue);
}
@end
