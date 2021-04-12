//
//  NSFileHandle+MCS.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileHandle (MCS)

+ (nullable instancetype)mcs_fileHandleForReadingFromURL:(NSURL *)url error:(out NSError **)error;

+ (nullable instancetype)mcs_fileHandleForWritingToURL:(NSURL *)url error:(out NSError **)error;

- (BOOL)mcs_seekToOffset:(NSUInteger)offset error:(out NSError **)error;

- (BOOL)mcs_seekToEndReturningOffset:(out unsigned long long *_Nullable)offsetInFile error:(out NSError **)error;

- (nullable NSData *)mcs_readDataUpToLength:(NSUInteger)length error:(out NSError **)error;

- (BOOL)mcs_writeData:(NSData *)data error:(out NSError **)error;

- (BOOL)mcs_synchronizeAndReturnError:(out NSError **)error;

- (BOOL)mcs_closeAndReturnError:(out NSError **)error;
@end

NS_ASSUME_NONNULL_END
