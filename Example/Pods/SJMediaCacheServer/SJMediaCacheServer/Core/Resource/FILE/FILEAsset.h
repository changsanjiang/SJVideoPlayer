//
//  MCSAsset.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAssetSubclass.h"

NS_ASSUME_NONNULL_BEGIN

@interface FILEAsset : MCSAsset

- (MCSAssetContent *)createContentWithOffset:(NSUInteger)offset response:(NSHTTPURLResponse *)response;

@property (nonatomic, copy, readonly, nullable) NSString *pathExtension;
@property (nonatomic, readonly) NSUInteger totalLength;
@end
NS_ASSUME_NONNULL_END
