//
//  SJPlaybackListControllerProtocol.h
//  Pods
//
//  Created by BlueDancer on 2019/1/23.
//

#ifndef SJPlaybackListControllerProtocol_h
#define SJPlaybackListControllerProtocol_h

@protocol SJMediaInfo, SJPlaybackListControllerObserver, SJPlaybackListControllerDelegate;

typedef enum : NSUInteger {
    SJPlaybackMode_ListCycle,       // 列表循环
    SJPlaybackMode_SingleCycle,     // 单曲循环
    SJPlaybackMode_RandomPlay,      // 随机播放
} SJPlaybackMode;

typedef enum : NSUInteger {
    SJSupportedPlaybackMode_ListCycle = 1 << 0,
    SJSupportedPlaybackMode_SingleCycle = 1 << 1,
    SJSupportedPlaybackMode_RandomPlay = 1 << 2,
    SJSupportedPlaybackMode_All = SJSupportedPlaybackMode_ListCycle | SJSupportedPlaybackMode_SingleCycle | SJSupportedPlaybackMode_RandomPlay,
} SJSupportedPlaybackMode;

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlaybackListController <NSObject>
@property (nonatomic, weak, nullable) id<SJPlaybackListControllerDelegate> delegate;
- (id<SJPlaybackListControllerObserver>)getObserver;

- (NSInteger)indexForMediaId:(NSInteger)mediaId; // 如果不存在, 将返回 NSNotFound
- (nullable id<SJMediaInfo>)mediaAtIndex:(NSInteger)index;
- (nullable id<SJMediaInfo>)mediaForMediaId:(NSInteger)mediaId;

// - add
- (void)addMedia:(id<SJMediaInfo>)media;
- (void)addToTheBackOfCurrentMedia:(id<SJMediaInfo>)media;
- (void)addMedias:(NSArray<id<SJMediaInfo>> *)medias;

// - replace
- (void)replaceMedias:(NSArray<id<SJMediaInfo>> *)medias;

// - remove
- (void)remove:(NSInteger)mediaId;
- (void)removeAllMedias;

// - playback mode
@property SJSupportedPlaybackMode supportedMode;
@property SJPlaybackMode mode; // 播放模式
- (void)changePlaybackMode;

// - play
- (void)playPreviousMedia;
- (void)playNextMedia;
- (void)playAtIndex:(NSInteger)idx;
- (void)currentMediaFinishedPlaying; // 当播放器播放完成后, 请调用这个方法, 告诉列表控制器当前的media已完成播放

- (nullable id<SJMediaInfo>)currentMedia;
- (NSArray<id<SJMediaInfo>> * _Nonnull)medias;
@end

@protocol SJPlaybackListControllerDelegate <NSObject>
- (void)listController:(id<SJPlaybackListController>)listController needToPlayMedia:(id<SJMediaInfo>)media;
- (void)listController:(id<SJPlaybackListController>)listController needToReplayCurrentMedia:(id<SJMediaInfo>)media;
- (void)currentMediaForListControllerIsRemoved:(id<SJPlaybackListController>)listController;
@end

@protocol SJMediaInfo <NSObject>
@property (nonatomic, readonly) NSInteger id;
@end

@protocol SJPlaybackListControllerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^prepareToPlayMediaExeBlock)(id<SJPlaybackListController> controller);
@property (nonatomic, copy, nullable) void(^playbackModeDidChangeExdBlock)(id<SJPlaybackListController> controller);
@property (nonatomic, copy, nullable) void(^listDidChangeExeBlock)(id<SJPlaybackListController> controller);
@end

extern NSNotificationName const SJPlaybackListControllerPrepareToPlayMediaNotification;
extern NSNotificationName const SJPlaybackListControllerPlaybackModeDidChangeNotification;
extern NSNotificationName const SJPlaybackListControllerListDidChangeNotification;
NS_ASSUME_NONNULL_END

#endif /* SJPlaybackListControllerProtocol_h */
