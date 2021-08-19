//
//  HLSAssetTsContent.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "MCSAssetContent.h"
#import "HLSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSAssetTsContent : MCSAssetContent<HLSAssetTsContent>
- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength length:(UInt64)length;
- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength;

- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength length:(UInt64)length rangeInAsset:(NSRange)range;
- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength rangeInAsset:(NSRange)range;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, readonly) NSRange rangeInAsset; // #EXT-X-BYTERANGE:1544984@1007868
@property (nonatomic, readonly) UInt64 totalLength; // `asset(EXT-X-BYTERANGE) or ts` total length

- (instancetype)initWithFilepath:(NSString *)filepath startPositionInAsset:(UInt64)position length:(UInt64)length NS_UNAVAILABLE;
- (instancetype)initWithFilepath:(NSString *)filepath startPositionInAsset:(UInt64)position NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
