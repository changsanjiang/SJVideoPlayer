//
//  MCSAssetContent.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MCSAssetContent : NSObject
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, readonly) NSUInteger length;
- (void)didWriteDataWithLength:(NSUInteger)length;
@end

@interface MCSAssetContent (FILE)
- (instancetype)initWithFilename:(NSString *)filename offset:(NSUInteger)offset;
- (instancetype)initWithFilename:(NSString *)filename offset:(NSUInteger)offset length:(NSUInteger)length;
@property (nonatomic, readonly) NSUInteger offset;
@end

@interface MCSAssetContent (HLS_TS)
- (instancetype)initWithFilename:(NSString *)filename tsName:(NSString *)tsName tsTotalLength:(NSUInteger)tsTotalLength length:(NSUInteger)length;
@property (nonatomic, copy, readonly) NSString *tsName;
@property (nonatomic, readonly) NSUInteger tsTotalLength;
@end
NS_ASSUME_NONNULL_END
