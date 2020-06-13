//
//  MCSResourceDefines.h
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#ifndef MCSResourceDefines_h
#define MCSResourceDefines_h
#import <Foundation/Foundation.h>
@protocol MCSResourceDataReaderDelegate;

NS_ASSUME_NONNULL_BEGIN
@protocol MCSResourceDataReader <NSObject>

@property (nonatomic, weak, nullable) id<MCSResourceDataReaderDelegate> delegate;

- (void)prepare;
@property (nonatomic, readonly) BOOL isDone;
- (nullable NSData *)readDataOfLength:(NSUInteger)length;
- (void)close;
@end

@protocol MCSResourceDataReaderDelegate <NSObject>
- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader;
- (void)readerHasAvailableData:(id<MCSResourceDataReader>)reader;
- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error;
@end

@protocol MCSReadWrite <NSObject>
@property (nonatomic, readonly) NSInteger readWriteCount;

- (void)readWrite_retain;
- (void)readWrite_release;
@end
NS_ASSUME_NONNULL_END
#endif /* MCSResourceDefines_h */
