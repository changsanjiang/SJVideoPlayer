//
//  MCSReadwrite.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "MCSInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSReadwrite : NSObject<MCSReadwriteReference>

@property (nonatomic, readonly) NSInteger readwriteCount; // kvo

- (void)readwriteRetain;
- (void)readwriteRelease;

@end

@interface MCSReadwrite (MCSReadwriteSubclassHooks)
- (void)readwriteCountDidChange:(NSInteger)count;
@end
NS_ASSUME_NONNULL_END
