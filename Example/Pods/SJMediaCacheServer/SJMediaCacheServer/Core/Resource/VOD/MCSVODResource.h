//
//  MCSResource.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceSubclass.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSVODResource : MCSResource

- (void)updateServer:(NSString * _Nullable)server contentType:(NSString * _Nullable)contentType totalLength:(NSUInteger)totalLength pathExtension:(nullable NSString *)pathExtension;
- (MCSResourcePartialContent *)createContentWithOffset:(NSUInteger)offset;

@property (nonatomic, copy, readonly, nullable) NSString *contentType;
@property (nonatomic, copy, readonly, nullable) NSString *server;
@property (nonatomic, readonly) NSUInteger totalLength;
@property (nonatomic, copy, readonly, nullable) NSString *pathExtension;
@end
NS_ASSUME_NONNULL_END
