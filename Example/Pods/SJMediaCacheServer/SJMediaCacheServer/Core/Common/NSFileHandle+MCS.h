//
//  NSFileHandle+MCS.h
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileHandle (MCS)

- (BOOL)mcs_seekToFileOffset:(NSUInteger)offset error:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END
