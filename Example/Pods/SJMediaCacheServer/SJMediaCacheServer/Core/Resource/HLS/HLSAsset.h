//
//  HLSAsset.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAssetSubclass.h"
#import "HLSParser.h"

NS_ASSUME_NONNULL_BEGIN
@interface HLSAsset : MCSAsset
@property (nonatomic, readonly) NSUInteger TsCount;
@property (nonatomic, strong, nullable) HLSParser *parser;


- (NSString *)filePathOfContent:(MCSAssetContent *)content;

- (nullable MCSAssetContent *)contentForTsURL:(NSURL *)URL;
- (MCSAssetContent *)createContentWithTsURL:(NSURL *)URL totalLength:(NSUInteger)totalLength;
@end
NS_ASSUME_NONNULL_END
