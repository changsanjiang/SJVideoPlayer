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
    [self _makeTestData];
}

- (void)_makeTestData {
    NSArray<NSURL *> *TestURLs = @[[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"],
                                   [NSURL URLWithString:@"https://www.apple.com/105/media/us/macbook-air/2018/9f419882_aefd_4083_902e_efcaee17a0b8/films/product/mba-product-tpl-cc-us-2018_1280x720h.mp4"],
                                   [NSURL URLWithString:@"https://www.apple.com/105/media/us/ipad-pro/2018/cE249dd1_58dc_487a_880b_6a1bc197cc43/films/product/ipad-pro-product-tpl-cc-us-2018_640x360h.mp4"]];
    
    NSMutableArray<TestMedia *> *medias = [NSMutableArray array];
    for ( int i = 1 ; i < 5; ++ i ) {
        TestMedia *media = [TestMedia new];
        media.id = i;
        media.viewHierarchy = [SJPlayModel new];
        media.URL = TestURLs[i % TestURLs.count];
        media.title = @"测试 测试";
        [medias addObject:media];
    }

    [_listController replaceMedias:medias]; // 当前列表替换为 medias
    [_listController playAtIndex:0];    // 播放第一个视频
    
    
#if 0
    /// Test
    for ( int i = 0 ; i < 999 ; ++ i ) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController addMedia:medias.firstObject];
        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController addToTheBackOfCurrentMedia:medias.lastObject];
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController addMedias:medias];
        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController replaceMedias:medias];
        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController remove:3];
        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController removeAllMedias];
        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController changePlaybackMode];
        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.listController.mode = SJPlaybackMode_SingleCycle;
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.listController medias];
        });
    }
#endif
    
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
        case SJPlaybackMode_ListCycle:
            return @"ListCycle";
        case SJPlaybackMode_SingleCycle:
            return @"SingleCycle";
        case SJPlaybackMode_RandomPlay:
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

- (void)_initializePlayer {
    _player = [SJVideoPlayer player];
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
}

- (void)_initializePlaybackListController {
    _listController = [SJPlaybackListController new];
    _listController.delegate = self;
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
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:testMedia.URL playModel:[SJPlayModel new]];
    _player.URLAsset.title = testMedia.title;
    _player.URLAsset.alwaysShowTitle = YES;
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
@end
