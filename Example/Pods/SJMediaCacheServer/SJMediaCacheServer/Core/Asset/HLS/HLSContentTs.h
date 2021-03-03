//
//  HLSContentTs.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "MCSInterfaces.h"
#import "FILEAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSContentTs : NSObject<MCSAssetContent>
- (instancetype)initWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength;
- (instancetype)initWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength length:(long long)length;

+ (instancetype)TsWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength inRange:(NSRange)range;
+ (instancetype)TsWithName:(NSString *)name filename:(NSString *)filename totalLength:(long long)totalLength inRange:(NSRange)range length:(long long)length;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, readonly) long long totalLength;
@property (nonatomic, readonly) long long length; // kvo
@property (nonatomic, readonly) NSRange range; // #EXT-X-BYTERANGE:1544984@1007868
- (void)didWriteDataWithLength:(NSUInteger)length;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
