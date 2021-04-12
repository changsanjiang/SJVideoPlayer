//
//  HLSContentProvider.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import <Foundation/Foundation.h>
#import "HLSContentTs.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSContentProvider : NSObject
- (instancetype)initWithDirectory:(NSString *)directory;

- (NSString *)indexFilePath;
- (NSString *)indexFileRelativePath;
- (NSString *)AESKeyFilePathWithName:(NSString *)AESKeyName;

- (nullable NSArray<HLSContentTs *> *)TsContents;
- (nullable HLSContentTs *)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength;
- (nullable HLSContentTs *)createTsContentWithName:(NSString *)name totalLength:(NSUInteger)totalLength inRange:(NSRange)range;
- (nullable NSString *)TsContentFilePathForFilename:(NSString *)filename;

- (void)removeTsContentForFilename:(NSString *)filename;
@end
NS_ASSUME_NONNULL_END
