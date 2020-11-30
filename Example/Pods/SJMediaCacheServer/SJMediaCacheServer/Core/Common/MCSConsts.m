//
//  MCSConsts.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "MCSConsts.h"
 
NSNotificationName const MCSAssetMetadataDidLoadNotification = @"MCSAssetMetadataDidLoadNotification";

NSNotificationName const MCSAssetWillRemoveAssetNotification = @"MCSAssetWillRemoveAssetNotification";
NSNotificationName const MCSAssetDidRemoveAssetNotification = @"MCSAssetDidRemoveAssetNotification";
   
NSString *const HLS_SUFFIX_INDEX   = @".m3u8";
NSString *const HLS_SUFFIX_TS      = @".ts";
NSString *const HLS_SUFFIX_AES_KEY = @".key";
