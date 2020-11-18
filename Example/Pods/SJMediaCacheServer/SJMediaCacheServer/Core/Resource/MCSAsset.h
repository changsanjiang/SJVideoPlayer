//
//  MCSAsset.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSInterfaces.h"
@class MCSAssetUsageLog, MCSAssetContent;

NS_ASSUME_NONNULL_BEGIN

@interface MCSAsset : NSObject<MCSAsset> {
    @protected
    NSMutableArray<MCSAssetContent *> *_m;
    BOOL _isCacheFinished;
    NSString *_name;
}

@property (nonatomic, readonly) MCSAssetType type;

- (id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request;

@property (nonatomic, strong, readonly) id<MCSConfiguration> configuration;

@property (nonatomic, strong, readonly) MCSAssetUsageLog *log;

@property (nonatomic, readonly) BOOL isCacheFinished;

- (nullable NSURL *)playbackURLForCacheWithURL:(NSURL *)URL;

- (void)prepareContents;
@end

NS_ASSUME_NONNULL_END
