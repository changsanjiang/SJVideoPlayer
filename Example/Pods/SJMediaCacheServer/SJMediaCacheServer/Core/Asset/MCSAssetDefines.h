//
//  MCSAssetDefines.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#ifndef MCSAssetDefines_h
#define MCSAssetDefines_h
#import <Foundation/Foundation.h>
@protocol MCSAssetDataReaderDelegate;

NS_ASSUME_NONNULL_BEGIN
@protocol MCSAssetDataReader <NSObject>

@property (nonatomic, weak, readonly, nullable) id<MCSAssetDataReaderDelegate> delegate;

- (void)prepare;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSUInteger availableLength;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isDone;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (BOOL)seekToOffset:(NSUInteger)offset;
- (void)close;
@end

@protocol MCSAssetDataReaderDelegate <NSObject>
- (void)readerPrepareDidFinish:(id<MCSAssetDataReader>)reader;
- (void)reader:(id<MCSAssetDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length;
- (void)reader:(id<MCSAssetDataReader>)reader anErrorOccurred:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
#endif /* MCSAssetDefines_h */
