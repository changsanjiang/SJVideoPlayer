//
//  MCSAssetContent.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "MCSReadwrite.h"
#import "MCSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSAssetContent : MCSReadwrite<MCSAssetContent>

/// Used for existing files
/// @param position 不是文件偏移量, 是该内容在整个资源中的位置
- (instancetype)initWithFilepath:(NSString *)filepath startPositionInAsset:(UInt64)position length:(UInt64)length;
/// Used for new files
- (instancetype)initWithFilepath:(NSString *)filepath startPositionInAsset:(UInt64)position;

- (nullable NSData *)readDataAtPosition:(UInt64)positionInAsset capacity:(UInt64)capacity error:(out NSError **)error;
@property (nonatomic, readonly) UInt64 startPositionInAsset;
@property (nonatomic, readonly) UInt64 length;
@property (nonatomic, copy, readonly) NSString *filepath;

- (void)registerObserver:(id<MCSAssetContentObserver>)observer;
- (void)removeObserver:(id<MCSAssetContentObserver>)observer;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
