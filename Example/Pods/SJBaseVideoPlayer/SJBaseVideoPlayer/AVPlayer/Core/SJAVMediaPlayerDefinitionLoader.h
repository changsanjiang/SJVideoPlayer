//
//  SJAVMediaPlayerDefinitionLoader.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/20.
//

#import "SJAVMediaPlayer.h"
@protocol SJAVMediaPlayerDefinitionLoaderDataSource, SJMediaModelProtocol;
@class SJAVMediaPresentView, SJAVMediaPresentController;

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayerDefinitionLoader : NSObject
- (instancetype)initWithMedia:(id<SJMediaModelProtocol>)media dataSource:(id<SJAVMediaPlayerDefinitionLoaderDataSource>)dataSource completionHandler:(void(^)(SJAVMediaPlayerDefinitionLoader *loader))completionHandler;
@property (nonatomic, strong, readonly) id<SJMediaModelProtocol> media;
@property (nonatomic, strong, readonly, nullable) SJAVMediaPlayer *player;
@property (nonatomic, strong, readonly, nullable) SJAVMediaPresentView *presentView;
@property (nonatomic, weak, readonly, nullable) id<SJAVMediaPlayerDefinitionLoaderDataSource> dataSource;
- (void)cancel;
@end

@protocol SJAVMediaPlayerDefinitionLoaderDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) SJAVMediaPlayer *player;
@property (nonatomic, strong, readonly) UIView *superview;
@property (nonatomic, strong, readonly) SJAVMediaPresentController *presentController;
@end
NS_ASSUME_NONNULL_END
