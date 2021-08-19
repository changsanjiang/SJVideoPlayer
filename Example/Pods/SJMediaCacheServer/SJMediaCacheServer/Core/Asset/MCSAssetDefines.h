//
//  MCSAssetDefines.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#ifndef MCSAssetDefines_h
#define MCSAssetDefines_h
#import "MCSInterfaces.h"
@protocol MCSAssetContentReaderDelegate, MCSAssetContentObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol MCSAssetContent <MCSReadwriteReference> 
- (nullable NSData *)readDataAtPosition:(UInt64)positionInAsset capacity:(UInt64)capacity error:(out NSError **)error;
- (BOOL)writeData:(NSData *)data error:(out NSError **)error;
- (void)closeWrite;
- (void)closeRead;
- (void)close;
@property (nonatomic, readonly) UInt64 startPositionInAsset;
@property (nonatomic, readonly) UInt64 length;

- (void)registerObserver:(id<MCSAssetContentObserver>)observer;
- (void)removeObserver:(id<MCSAssetContentObserver>)observer;

@end

@protocol MCSAssetContentObserver <NSObject>
- (void)content:(id<MCSAssetContent>)content didWriteDataWithLength:(NSUInteger)length;
@end


#pragma mark - mark

@protocol MCSAssetContentReader <NSObject>

@property (nonatomic, weak, readonly, nullable) id<MCSAssetContentReaderDelegate> delegate;

- (void)prepare;
@property (nonatomic, strong, readonly, nullable) __kindof id<MCSAssetContent> content;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) UInt64 availableLength;
@property (nonatomic, readonly) UInt64 offset;
@property (nonatomic, readonly) MCSReaderStatus status;
- (nullable NSData *)readDataOfLength:(UInt64)length;
- (BOOL)seekToOffset:(UInt64)offset;
- (void)abortWithError:(nullable NSError *)error;
@end

@protocol MCSAssetContentReaderDelegate <NSObject>
- (void)readerWasReadyToRead:(id<MCSAssetContentReader>)reader;
- (void)reader:(id<MCSAssetContentReader>)reader hasAvailableDataWithLength:(NSUInteger)length;
- (void)reader:(id<MCSAssetContentReader>)reader didAbortWithError:(nullable NSError *)error;
@end


@protocol MCSAssetContentReaderSubclass <NSObject>
// hooks
- (void)prepareContent;
- (void)didAbortWithError:(nullable NSError *)error;

// subclass callback
- (void)preparationDidFinishWithContentReadwrite:(id<MCSAssetContent>)content range:(NSRange)range;
@end
NS_ASSUME_NONNULL_END
#endif /* MCSAssetDefines_h */
