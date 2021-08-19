//
//  MCSConsts.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "MCSConsts.h"
 
NSNotificationName const MCSAssetMetadataDidLoadNotification = @"MCSAssetMetadataDidLoadNotification";
NSNotificationName const MCSFileWriteOutOfSpaceErrorNotification = @"MCSFileWriteOutOfSpaceErrorNotification";

NSString *const HLS_SUFFIX_INDEX   = @".m3u8";
NSString *const HLS_SUFFIX_TS      = @".ts";
NSString *const HLS_SUFFIX_AES_KEY = @".key";

NSInteger const MCS_RESPONSE_CODE_OK = 200;
NSInteger const MCS_RESPONSE_CODE_PARTIAL_CONTENT = 206;
NSInteger const MCS_RESPONSE_CODE_BAD = 400;
 
NSString *const kLength = @"length";
