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

@interface ViewControllerPlaybackListController ()<SJRouteHandler>
@property (nonatomic, strong, readonly) id<SJPlaybackListControllerObserver> listControllerObserver;
@property (nonatomic, strong, readonly) SJPlaybackListController *listController;
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
}

- (void)_initializeListControllerObserver {
    _listControllerObserver = [_listController getObserver];
    __weak typeof(self) _self = self;
    _listControllerObserver.playbackModeDidChangeExdBlock = ^(id<SJPlaybackListController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updatePlaybackModeItem];
    };
}

#pragma mark -

static SJEdgeControlButtonItemTag SJEdgeControlButtonItem_PlaybackMode = 100;
static SJEdgeControlButtonItemTag SJEdgeControlButtonItem_PlayNextMedia = 101;

- (void)_addButtonItemsToEdgeControlLayer {
    SJVideoPlayer *player = _listController.player;
    
    // 播放模式按钮 (列表循环/单曲循环/随机播放)
    SJEdgeControlButtonItem *playbackModeItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlButtonItem_PlaybackMode];
    [player.defaultEdgeControlLayer.bottomAdapter insertItem:playbackModeItem frontItem:SJEdgeControlLayerBottomItem_Play];
    [playbackModeItem addTarget:self action:@selector(handleClickedPlaybackModeItemEvent:)];

    // 下一曲按钮
    SJEdgeControlButtonItem *playNextMediaItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlButtonItem_PlayNextMedia];
    [player.defaultEdgeControlLayer.bottomAdapter insertItem:playNextMediaItem frontItem:SJEdgeControlButtonItem_PlaybackMode];
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
    SJVideoPlayer *player = _listController.player;
    SJEdgeControlButtonItem *playbackModeItem = [player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlButtonItem_PlaybackMode];
    __weak typeof(self) _self = self;
    [self _loadImageWithName:[self _imageNameOfPlaybackMode] callback:^(UIImage * _Nullable img) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        playbackModeItem.image = img;
        [player.defaultEdgeControlLayer.bottomAdapter reload];
    }];
}

- (void)_updatePlayNextMediaItem {
    SJVideoPlayer *player = _listController.player;
    SJEdgeControlButtonItem *playNextMediaItem = [player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlButtonItem_PlayNextMedia];
    __weak typeof(self) _self = self;
    [self _loadImageWithName:@"Next" callback:^(UIImage * _Nullable img) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        playNextMediaItem.image = img;
        [player.defaultEdgeControlLayer.bottomAdapter reload];
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

- (void)_initializePlaybackListController {
    _listController = [[SJPlaybackListController alloc] initWithPlayer:[SJVideoPlayer player]];

    [self.view addSubview:_listController.player.view];
    [_listController.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.leading.trailing.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9 / 16.0f);
    }];
}

@end
