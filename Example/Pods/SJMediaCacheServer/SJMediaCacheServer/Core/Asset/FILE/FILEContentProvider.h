//
//  FILEContentProvider.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/24.
//

#import <Foundation/Foundation.h>
#import "FILEContent.h"

NS_ASSUME_NONNULL_BEGIN
@interface FILEContentProvider : NSObject
+ (instancetype)contentProviderWithDirectory:(NSString *)directory;
- (nullable NSArray<FILEContent *> *)contents;
- (nullable FILEContent *)createContentAtOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension;
- (nullable NSString *)contentFilePathForFilename:(NSString *)filename;
- (void)removeContentForFilename:(NSString *)filename;
@end
NS_ASSUME_NONNULL_END
