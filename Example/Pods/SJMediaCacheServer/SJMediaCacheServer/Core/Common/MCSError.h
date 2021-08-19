//
//  MCSError.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MCSErrorCode) {
    MCSUnknownError = 100000,
    MCSExceptionError,
    MCSFileError,
    MCSInvalidRequestError,
    MCSInvalidResponseError,
    MCSInvalidParameterError,
    MCSAbortError,
};

FOUNDATION_EXTERN NSString *const MCSErrorDomain;
FOUNDATION_EXTERN NSString *const MCSErrorUserInfoObjectKey;
FOUNDATION_EXTERN NSString *const MCSErrorUserInfoReasonKey;
FOUNDATION_EXTERN NSString *const MCSErrorUserInfoExceptionKey;
FOUNDATION_EXTERN NSString *const MCSErrorUserInfoErrorKey;

@interface NSError (MCSExtended)

+ (NSError *)mcs_errorWithCode:(MCSErrorCode)code userInfo:(NSDictionary *)userInfo;

@end
NS_ASSUME_NONNULL_END
