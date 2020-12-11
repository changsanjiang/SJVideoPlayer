//
//  MCSConsts.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const MCSAssetMetadataDidLoadNotification;

FOUNDATION_EXPORT NSNotificationName const MCSAssetWillRemoveAssetNotification;
FOUNDATION_EXPORT NSNotificationName const MCSAssetDidRemoveAssetNotification;

FOUNDATION_EXPORT NSString *const HLS_SUFFIX_INDEX;
FOUNDATION_EXPORT NSString *const HLS_SUFFIX_TS;
FOUNDATION_EXPORT NSString *const HLS_SUFFIX_AES_KEY;
NS_ASSUME_NONNULL_END
