//
//  MCSConsts.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const MCSAssetMetadataDidLoadNotification;
FOUNDATION_EXPORT NSNotificationName const MCSFileWriteOutOfSpaceErrorNotification;

FOUNDATION_EXPORT NSString *const HLS_SUFFIX_INDEX;
FOUNDATION_EXPORT NSString *const HLS_SUFFIX_TS;
FOUNDATION_EXPORT NSString *const HLS_SUFFIX_AES_KEY;

FOUNDATION_EXPORT NSInteger const MCS_RESPONSE_CODE_OK;
FOUNDATION_EXPORT NSInteger const MCS_RESPONSE_CODE_PARTIAL_CONTENT;
FOUNDATION_EXPORT NSInteger const MCS_RESPONSE_CODE_BAD;

FOUNDATION_EXPORT NSString *const kLength;
NS_ASSUME_NONNULL_END
