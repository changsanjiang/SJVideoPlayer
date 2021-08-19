//
//  FILEAssetContentProvider.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/24.
//

#import "MCSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface FILEAssetContentProvider : NSObject
+ (instancetype)contentProviderWithDirectory:(NSString *)directory;
- (nullable NSArray<id<MCSAssetContent>> *)contents;
- (nullable id<MCSAssetContent>)createContentAtOffset:(NSUInteger)offset pathExtension:(nullable NSString *)pathExtension;
- (nullable NSString *)contentFilepath:(id<MCSAssetContent>)content;
- (void)removeContent:(id<MCSAssetContent>)content;
@end
NS_ASSUME_NONNULL_END
