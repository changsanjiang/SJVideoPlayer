//
//  HLSAssetDefines.h
//  Pods
//
//  Created by 畅三江 on 2021/7/19.
//

#ifndef HLSAssetDefines_h
#define HLSAssetDefines_h

#import "MCSAssetDefines.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HLSAssetTsContent <MCSAssetContent>
@property (nonatomic, copy, readonly) NSString *name; // `ts name`
@property (nonatomic, readonly) NSRange rangeInAsset; // #EXT-X-BYTERANGE:1544984@1007868
@property (nonatomic, readonly) UInt64 totalLength; // `asset(EXT-X-BYTERANGE) or ts` total length
@end
NS_ASSUME_NONNULL_END
#endif /* HLSAssetDefines_h */
