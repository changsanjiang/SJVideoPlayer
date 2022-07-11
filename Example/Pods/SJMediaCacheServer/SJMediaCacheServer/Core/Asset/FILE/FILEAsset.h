//
//  MCSAsset.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
#import "MCSAssetDefines.h"
#import "MCSReadwrite.h"
@protocol FILEAssetContentNode;

NS_ASSUME_NONNULL_BEGIN
@interface FILEAsset : MCSReadwrite<MCSAsset>
@property (nonatomic, readonly) MCSAssetType type;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) id<MCSConfiguration> configuration;
@property (nonatomic, copy, readonly, nullable) NSString *pathExtension; // notify
@property (nonatomic, copy, readonly, nullable) NSString *contentType; // notify
@property (nonatomic, readonly) NSUInteger totalLength; // notify
@property (nonatomic, readonly) BOOL isStored; 

- (nullable id<MCSAssetContent>)createContentReadwriteWithDataType:(MCSDataType)dataType response:(id<MCSDownloadResponse>)response;
- (nullable NSString *)filepathForContent:(id<MCSAssetContent>)content;
- (void)enumerateContentNodesUsingBlock:(void(NS_NOESCAPE ^)(id<FILEAssetContentNode> node, BOOL *stop))block;
@end

@protocol FILEAssetContentNode <NSObject>
@property (nonatomic, readonly) UInt64 startPositionInAsset;
@property (nonatomic, readonly, nullable) NSArray<id<MCSAssetContent>> *allContents;
@property (nonatomic, readonly, nullable) id<MCSAssetContent> longestContent;
@end
NS_ASSUME_NONNULL_END
