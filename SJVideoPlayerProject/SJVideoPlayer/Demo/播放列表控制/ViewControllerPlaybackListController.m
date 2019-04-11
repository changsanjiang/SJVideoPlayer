//
//  ViewControllerPlaybackListController.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/1/23.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "ViewControllerPlaybackListController.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import "SJPlaybackListController.h"
#import "TestMedia.h"
#import <SJBaseVideoPlayer/SJVideoPlayerURLAssetPrefetcher.h>
#import "SJRemoteCommandHandler.h"

@interface ViewControllerPlaybackListController ()<SJRouteHandler, SJPlaybackListControllerDelegate>
@property (nonatomic, strong, readonly) id<SJPlaybackListControllerObserver> listControllerObserver;
@property (nonatomic, strong, readonly) SJPlaybackListController *listController;
@property (nonatomic, strong, readonly) SJVideoPlayer *player;
@end

@implementation ViewControllerPlaybackListController
+ (NSString *)routePath {
    return @"playbackListController";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initializePlayer];
    [self _initializePlaybackListController];
    [self _initializeListControllerObserver];
    [self _addButtonItemsToEdgeControlLayer];
    [self _configRemoteCommandHandler];
    
    // 创建资源, 并进行预加载
    [self _makeTestData];
}

- (void)_makeTestData {
    
    NSArray<NSURL *> *testURLs =
  @[[NSURL URLWithString:@"https://xy2.v.netease.com/r/video/20190308/31cbdd25-3cc9-49d4-934c-8d29b54fc15b.mp4"],
    [NSURL URLWithString:@"https://xy2.v.netease.com/2018/0815/2b4c5207f8977c183897728dc6c77d58qt.mp4"],
    [NSURL URLWithString:@"https://xy2.v.netease.com/2018/0815/c4f8e15cf43e4404911c2e9d17d89d3fqt.mp4"],
    [NSURL URLWithString:@"https://xy2.v.netease.com/2018/0815/d08adab31cc9e6ce36111afc8a92c937qt.mp4"],
    [NSURL URLWithString:@"https://xy2.v.netease.com/2018/0815/bedf0f6f6573ca36c041932f4f601f06qt.mp4"]];
    
    NSMutableArray<TestMedia *> *videos = [NSMutableArray array];
    for ( int i = 0 ; i < testURLs.count; ++ i ) {
        TestMedia *media = [TestMedia new];
        media.id = i;
        media.URL = testURLs[i];
        media.title = @"一生所爱";
        media.viewHierarchy = [SJPlayModel new];
        [videos addObject:media];
        
        // 进行预加载
        SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:media.URL playModel:[SJPlayModel new]];
        asset.title = media.title;
        [SJVideoPlayerURLAssetPrefetcher.shared prefetchAsset:asset];
    }

    // 添加到 播放列表
    [_listController replaceMedias:videos];
    // 播放 第一个视频
    [_listController playAtIndex:0];
}

#pragma mark -

static SJEdgeControlButtonItemTag SJEdgeControlButtonItem_PlaybackMode = 100;
static SJEdgeControlButtonItemTag SJEdgeControlButtonItem_PlayNextMedia = 101;

- (void)_addButtonItemsToEdgeControlLayer {
    // 播放模式按钮 (列表循环/单曲循环/随机播放)
    SJEdgeControlButtonItem *playbackModeItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlButtonItem_PlaybackMode];
    [_player.defaultEdgeControlLayer.bottomAdapter insertItem:playbackModeItem frontItem:SJEdgeControlLayerBottomItem_Play];
    [playbackModeItem addTarget:self action:@selector(handleClickedPlaybackModeItemEvent:)];

    // 下一曲按钮
    SJEdgeControlButtonItem *playNextMediaItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlButtonItem_PlayNextMedia];
    [_player.defaultEdgeControlLayer.bottomAdapter insertItem:playNextMediaItem frontItem:SJEdgeControlButtonItem_PlaybackMode];
    [playNextMediaItem addTarget:self action:@selector(handleClickedPlayNextMediaItemEvent:)];
    
    // 更新
    [self _updatePlaybackModeItem];
    [self _updatePlayNextMediaItem];
}

- (void)handleClickedPlaybackModeItemEvent:(SJEdgeControlButtonItem *)item {
    [_listController changePlaybackMode]; // 改变播放模式
}

- (void)handleClickedPlayNextMediaItemEvent:(SJEdgeControlButtonItem *)item {
    [_listController playNextMedia]; // 下一个视频
}

- (void)_updatePlaybackModeItem {
    SJEdgeControlButtonItem *playbackModeItem = [_player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlButtonItem_PlaybackMode];
    __weak typeof(self) _self = self;
    [self _loadImageWithName:[self _imageNameOfPlaybackMode] callback:^(UIImage * _Nullable img) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        playbackModeItem.image = img;
        [self.player.defaultEdgeControlLayer.bottomAdapter reload];
    }];
}

- (void)_updatePlayNextMediaItem {
    SJEdgeControlButtonItem *playNextMediaItem = [_player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlButtonItem_PlayNextMedia];
    __weak typeof(self) _self = self;
    [self _loadImageWithName:@"Next" callback:^(UIImage * _Nullable img) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        playNextMediaItem.image = img;
        [self.player.defaultEdgeControlLayer.bottomAdapter reload];
    }];
}

- (NSString *)_imageNameOfPlaybackMode {
    switch ( self.listController.mode ) {
        case SJPlaybackMode_InOrder:
            return @"ListCycle";
        case SJPlaybackMode_RepeatOne:
            return @"SingleCycle";
        case SJPlaybackMode_Shuffle:
            return @"RandomPlay";
    }
}

- (void)_loadImageWithName:(NSString *)name callback:(void(^)(UIImage *_Nullable img))callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *img = [UIImage imageNamed:name];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( callback ) callback(img);
        });
    });
}

#pragma mark -
- (void)_configRemoteCommandHandler {
    __weak typeof(self) _self = self;
    SJRemoteCommandHandler.shared.pauseCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player pause];
    };
    
    SJRemoteCommandHandler.shared.playCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player play];
    };
    
    SJRemoteCommandHandler.shared.previousCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.listController playPreviousMedia];
    };
    
    SJRemoteCommandHandler.shared.nextCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.listController playNextMedia];
    };
    
    SJRemoteCommandHandler.shared.seekToTimeCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler, NSTimeInterval secs) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player seekToTime:secs completionHandler:nil];
    };
}

#pragma mark -

- (void)_initializePlayer {
    _player = [SJVideoPlayer player];
    _player.pauseWhenAppDidEnterBackground = NO;
    _player.defaultEdgeControlLayer.showResidentBackButton = YES;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.leading.trailing.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    __weak typeof(self) _self = self;
    _player.playDidToEndExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.listController currentMediaFinishedPlaying]; // 通知listController, 当前已播放完毕
    };
    
    _player.playTimeDidChangeExeBlok = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [SJRemoteCommandHandler.shared updateNowPlayingInfo:
         @{MPMediaItemPropertyTitle:@"十五年前, 一见钟情",
           MPMediaItemPropertyMediaType:@(MPMediaTypeAnyAudio),
           MPNowPlayingInfoPropertyElapsedPlaybackTime:@(videoPlayer.currentTime),
           MPMediaItemPropertyPlaybackDuration:@(videoPlayer.totalTime),
           MPNowPlayingInfoPropertyPlaybackRate:@(videoPlayer.rate),
           MPMediaItemPropertyArtist:@"Artist",
           MPMediaItemPropertyAlbumArtist:@"AlbumArtist"}];
    };
}

- (void)_initializePlaybackListController {
    _listController = [SJPlaybackListController new];
    _listController.delegate = self;
    _listController.recycle = YES;
}

- (void)_initializeListControllerObserver {
    _listControllerObserver = [_listController getObserver];
    __weak typeof(self) _self = self;
    _listControllerObserver.playbackModeDidChangeExdBlock = ^(id<SJPlaybackListController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updatePlaybackModeItem];
    };
    
    _listControllerObserver.listDidChangeExeBlock = ^(id<SJPlaybackListController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( 0 == controller.medias.count ) {
            [self.player stop];
        }
    };
}

/// 需要播放下一个media
- (void)listController:(id<SJPlaybackListController>)listController needToPlayMedia:(id<SJMediaInfo>)media {
    TestMedia *testMedia = media;
    // 是否预加载过
    SJVideoPlayerURLAsset *_Nullable asset = [SJVideoPlayerURLAssetPrefetcher.shared assetForURL:testMedia.URL];
    if ( !asset ) {
        // 创建一个新的资源
        asset = [[SJVideoPlayerURLAsset alloc] initWithURL:testMedia.URL playModel:[SJPlayModel new]];
        asset.title = testMedia.title;
    }
    _player.URLAsset = asset;
}

/// 需要重新播放
- (void)listController:(id<SJPlaybackListController>)listController needToReplayCurrentMedia:(id<SJMediaInfo>)media {
    [_player replay];
}

/// 当前播放的 media 被移除的回调
- (void)currentMediaForListControllerIsRemoved:(id<SJPlaybackListController>)listController {
    [_player stop];
    [listController playNextMedia];
}


#pragma mark -
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end
