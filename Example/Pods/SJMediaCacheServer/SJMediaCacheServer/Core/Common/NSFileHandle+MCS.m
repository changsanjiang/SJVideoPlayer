//
//  NSFileHandle+MCS.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/9.
//

#import "NSFileHandle+MCS.h"
#import "MCSError.h"

@implementation NSFileHandle (MCS)

+ (nullable instancetype)mcs_fileHandleForReadingFromURL:(NSURL *)url error:(out NSError **)outError {
    NSError *error = nil;
    NSFileHandle *reader = [NSFileHandle fileHandleForReadingFromURL:url error:&error];
    if ( error != nil && outError != NULL ) {
        *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
            MCSErrorUserInfoErrorKey : error,
            MCSErrorUserInfoReasonKey : @"`FileHandle`初始化失败, 文件不存在或其他错误!"
        }];
    }
    
    return reader;
}

+ (nullable instancetype)mcs_fileHandleForWritingToURL:(NSURL *)url error:(out NSError **)outError {
    NSError *error = nil;
    NSFileHandle *reader = [NSFileHandle fileHandleForWritingToURL:url error:&error];
    if ( error != nil && outError != NULL ) {
        *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
            MCSErrorUserInfoErrorKey : error,
            MCSErrorUserInfoReasonKey : @"`FileHandle`初始化失败, 文件不存在或其他错误!"
        }];
    }
    return reader;
}

- (BOOL)mcs_seekToOffset:(NSUInteger)offset error:(out NSError **)outError {
    NSError *error = nil;
    BOOL result = NO;
    if ( @available(iOS 13.0, *) ) {
        result = [self seekToOffset:offset error:&error];
    }
    else {
        @try {
            [self seekToFileOffset:offset];
            result = YES;
        } @catch (NSException *exception) {
            error = [NSError mcs_errorWithCode:MCSExceptionError userInfo:@{
                MCSErrorUserInfoExceptionKey : exception
            }];
        }
    }
    
    if ( error != nil && outError != NULL ) *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
        MCSErrorUserInfoErrorKey : error,
        MCSErrorUserInfoReasonKey : @"文件跳转失败!"
    }];
    return result;
}

- (nullable NSData *)mcs_readDataUpToLength:(NSUInteger)length error:(out NSError **)outError {
    NSError *error = nil;
    NSData *data = nil;
    if ( @available(iOS 13.0, *) ) {
        data = [self readDataUpToLength:length error:&error];
    }
    else {
        @try {
            data = [self readDataOfLength:length];
        } @catch (NSException *exception) {
            error = [NSError mcs_errorWithCode:MCSExceptionError userInfo:@{
                MCSErrorUserInfoExceptionKey : exception
            }];
        }
    }
    if ( error != nil && outError != NULL ) *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
        MCSErrorUserInfoErrorKey : error,
        MCSErrorUserInfoReasonKey : @"文件读取失败!"
    }];
    return data;
}

- (BOOL)mcs_writeData:(NSData *)data error:(out NSError **)outError {
    NSError *error = nil;
    BOOL result = NO;
    if ( @available(iOS 13.0, *) ) {
        result = [self writeData:data error:&error];
    }
    else {
        @try {
            [self writeData:data];
            result = YES;
        } @catch (NSException *exception) {
            error = [NSError mcs_errorWithCode:MCSExceptionError userInfo:@{
                MCSErrorUserInfoExceptionKey : exception
            }];
        }
    }
    
    if ( error != nil && outError != NULL ) *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
        MCSErrorUserInfoErrorKey : error,
        MCSErrorUserInfoReasonKey : @"文件写入失败!"
    }];
    return result;
}

- (BOOL)mcs_synchronizeAndReturnError:(out NSError **)outError {
    NSError *error = nil;
    BOOL result = NO;
    if ( @available(iOS 13.0, *) ) {
        result = [self synchronizeAndReturnError:&error];
    }
    else {
        @try {
            [self synchronizeFile];
            result = YES;
        } @catch (NSException *exception) {
            error = [NSError mcs_errorWithCode:MCSExceptionError userInfo:@{
                MCSErrorUserInfoExceptionKey : exception,
            }];
        }
    }
    
    if ( error != nil && outError != NULL ) *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
        MCSErrorUserInfoErrorKey : error,
        MCSErrorUserInfoReasonKey : @"文件同步失败!"
    }];
    return result;
}

- (BOOL)mcs_closeAndReturnError:(out NSError **)outError {
    NSError *error = nil;
    BOOL result = NO;
    if ( @available(iOS 13.0, *) ) {
        result = [self closeAndReturnError:&error];
    }
    else {
        @try {
            [self closeFile];
            result = YES;
        } @catch (NSException *exception) {
            error = [NSError mcs_errorWithCode:MCSExceptionError userInfo:@{
                MCSErrorUserInfoExceptionKey : exception,
            }];
        }
    }
    
    if ( error != nil && outError != NULL ) *outError = [NSError mcs_errorWithCode:MCSFileError userInfo:@{
        MCSErrorUserInfoErrorKey : error,
        MCSErrorUserInfoReasonKey : @"文件关闭失败!"
    }];
    return result;
}
@end
