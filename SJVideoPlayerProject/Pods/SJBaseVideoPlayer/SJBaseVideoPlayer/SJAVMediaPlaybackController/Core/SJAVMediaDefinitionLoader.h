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
- (instancetype)initWithMedia:(id<SJMediaModelProtocol>)media handler:(void(^)(SJAVMediaDefinitionLoader *loader, AVPlayerItemStatus status))handler;

@property (nonatomic, strong, readonly) id<SJMediaModelProtocol> media;
@property (nonatomic, strong, readonly, nullable) id<SJAVMediaPlayerProtocol> player;
@end
NS_ASSUME_NONNULL_END
