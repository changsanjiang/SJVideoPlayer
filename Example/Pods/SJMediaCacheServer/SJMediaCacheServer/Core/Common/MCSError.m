//
//  MCSError.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSError.h"

NSString *const MCSErrorDomain = @"lib.changsanjiang.SJMediaCacheServer.error";
NSString *const MCSErrorUserInfoObjectKey = @"object";
NSString *const MCSErrorUserInfoReasonKey = @"reason";
NSString *const MCSErrorUserInfoExceptionKey = @"exception";
NSString *const MCSErrorUserInfoErrorKey = @"error";

@implementation NSError(MCSExtended)

+ (NSError *)mcs_errorWithCode:(MCSErrorCode)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:MCSErrorDomain code:code userInfo:userInfo];
}

@end
