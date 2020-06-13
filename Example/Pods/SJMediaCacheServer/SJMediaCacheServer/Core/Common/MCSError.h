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
    MCSResponseUnavailableError    = 100000,
    MCSResourceHasBeenRemovedError = 100001,
    MCSNonsupportContentTypeError  = 100002,
    MCSExceptionError              = 100003,

    // unused
//    MCSOutOfDiskSpaceError        = 100004,
    
    MCSHLSFileParseError           = 100005,
    
    MCSFileHandleError             = 100006,
};

FOUNDATION_EXTERN NSString * const MCSErrorDomain;
FOUNDATION_EXTERN NSString * const MCSErrorUserInfoURLKey;
FOUNDATION_EXTERN NSString * const MCSErrorUserInfoRequestKey;
FOUNDATION_EXTERN NSString * const MCSErrorUserInfoResponseKey;


@interface NSError (MCSExtended)
+ (NSError *)mcs_errorForResponseUnavailable:(NSURL *)URL request:(NSURLRequest *)request response:(NSURLResponse *)response;

+ (NSError *)mcs_errorForNonsupportContentType:(NSURL *)URL request:(NSURLRequest *)request response:(NSURLResponse *)response;

+ (NSError *)mcs_errorForException:(NSException *)exception;

+ (NSError *)mcs_errorForRemovedResource:(NSURL *)URL;

+ (NSError *)mcs_errorForHLSFileParseError:(NSURL *)URL;

+ (NSError *)mcs_errorForFileHandleError:(NSURL *)URL;
@end
NS_ASSUME_NONNULL_END
