//
//  SJAVMediaDefinitionLoader.h
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "SJAVMediaPlayerLoader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaDefinitionLoader : NSObject
- (instancetype)initWithMedia:(id<SJMediaModelProtocol>)media assetStatudDidChangeHandler:(void(^)(SJAVMediaDefinitionLoader *loader))handler;

@property (nonatomic, strong, readonly) id<SJMediaModelProtocol> media;
@property (nonatomic, strong, readonly, nullable) SJAVMediaPlayer * player;
@end
NS_ASSUME_NONNULL_END
