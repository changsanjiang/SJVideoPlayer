//
//  FILEContent.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/24.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface FILEContent : NSObject<MCSAssetContent>
- (instancetype)initWithFilename:(NSString *)filename atOffset:(NSUInteger)offset;
- (instancetype)initWithFilename:(NSString *)filename atOffset:(NSUInteger)offset length:(NSUInteger)length;
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) long long length; // kvo
- (void)didWriteDataWithLength:(NSUInteger)length;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
