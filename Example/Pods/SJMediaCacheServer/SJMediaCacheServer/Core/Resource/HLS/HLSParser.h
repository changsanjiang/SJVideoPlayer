//
//  HLSParser.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HLSParserDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface HLSParser : NSObject
+ (nullable instancetype)parserInAssetIfExists:(NSString *)assetName;

- (instancetype)initWithAsset:(NSString *)assetName request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<HLSParserDelegate>)delegate;

- (void)prepare;

- (void)close;

@property (nonatomic, copy, readonly) NSString *assetName;
@property (nonatomic, copy, readonly) NSString *indexFilePath;
@property (nonatomic, readonly) NSUInteger TsCount;
@property (nonatomic, readonly) BOOL isClosed;
@property (nonatomic, readonly) BOOL isDone;

- (nullable NSString *)URIAtIndex:(NSUInteger)index;
@end


@protocol HLSParserDelegate <NSObject>
- (void)parserParseDidFinish:(HLSParser *)parser;
- (void)parser:(HLSParser *)parser anErrorOccurred:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
