//
//  SJViewController1.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController1.h"
#import "SJTableViewCell1.h"
#import "SJVideoModel.h"
#import <SJUIKit/SJUIKit.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import "SJRemoteCommandHandler.h"
#import "SJBaseVideoPlayer+ListPlaybackExtended.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *const SJTableViewCell1ID = @"SJTableViewCell1";

@interface SJViewController1 ()<UITableViewDelegate, UITableViewDataSource, SJBaseVideoPlayerAssetProvider>
@property (weak, nonatomic) IBOutlet UIView *playerContainerVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@property (nonatomic, strong) NSMutableArray<SJVideoModel *> *videos;
@end

@implementation SJViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _setupRemoteCommandHandler];
    [self.tableView sj_exeHeaderRefreshingAnimated:YES];
}

#pragma mark -

- (IBAction)playPreviousMedia:(id)sender {
    [_player playPreviousAsset];
}

- (IBAction)playNextMedia:(id)sender {
    [_player playNextAsset];
}

#pragma mark - SJBaseVideoPlayerAssetProvider

- (SJVideoPlayerURLAsset *)videoPlayer:(__kindof SJBaseVideoPlayer *)player assetAtIndex:(NSInteger)index {
    SJVideoModel *item = self.videos[index];
 
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:item.URL];
    asset.title = item.mediaTitle;
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    return asset;
}

#pragma mark -

- (void)_setupVideoPlayer {
    _player = [SJVideoPlayer player];
    _player.pausedInBackground = NO; ///< 开启后台播放
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    
    _player.assetProvider = self;
    // 在控制层添加下一首按钮
    SJEdgeControlButtonItem *nextItem = [[SJEdgeControlButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"] target:_player action:@selector(playNextAsset) tag:1000];
    [_player.defaultEdgeControlLayer.bottomAdapter insertItem:nextItem frontItem:SJEdgeControlLayerBottomItem_Play];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    
    [_playerContainerVIew addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    _player.playbackObserver.currentTimeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        SJVideoModel *item = self.videos[player.currentAssetIndex];
        NSDictionary *info =
        @{MPMediaItemPropertyTitle:item.mediaTitle,
          MPMediaItemPropertyMediaType:@(MPMediaTypeAny),
          MPNowPlayingInfoPropertyElapsedPlaybackTime:@(player.currentTime),
          MPMediaItemPropertyPlaybackDuration:@(player.duration),
          MPNowPlayingInfoPropertyPlaybackRate:@(player.rate)};
        [SJRemoteCommandHandler.shared updateNowPlayingInfo:info];
    };
}

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

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)_setupRemoteCommandHandler {
    __weak typeof(self) _self = self;
    SJRemoteCommandHandler.shared.pauseCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player pause];
    };
    
    SJRemoteCommandHandler.shared.playCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player play];
    };
    
    SJRemoteCommandHandler.shared.previousCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player playPreviousAsset];
    };
    
    SJRemoteCommandHandler.shared.nextCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player playNextAsset];
    };
    
    SJRemoteCommandHandler.shared.seekToTimeCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler, NSTimeInterval secs) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player seekToTime:secs completionHandler:nil];
    };
}
 
#pragma mark -

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);
    
    _videos = NSMutableArray.array;
    
    [self _setupVideoPlayer];
    [self _setupTableView];
}

- (void)_setupTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.rowHeight = 44;
    [_tableView registerNib:[UINib nibWithNibName:SJTableViewCell1ID bundle:nil] forCellReuseIdentifier:SJTableViewCell1ID];
    
    __weak typeof(self) _self = self;
    [_tableView sj_setupRefreshingWithPageSize:20 beginPageNum:1 refreshingBlock:^(UITableView *tableView, NSInteger requestPageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        // 模拟数据
        NSMutableArray<SJVideoModel *> *videos = [NSMutableArray arrayWithCapacity:tableView.sj_pageSize];
        for ( int i = 0; i < tableView.sj_pageSize ; ++ i ) {
            SJVideoModel *model = [SJVideoModel testItem];
            [videos addObject:model];
        }
        
        if ( requestPageNum == tableView.sj_beginPageNum ) {
            [self.videos removeAllObjects];
        }
        
        [self.videos addObjectsFromArray:videos];
        
        // 刷新数量
        self.player.numberOfAssets = self.videos.count;
        [self.tableView reloadData];
        [self.tableView sj_endRefreshingWithItemCount:videos.count];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_player playAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:SJTableViewCell1ID forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJTableViewCell1 *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoModel *item = _videos[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld: %@", (long)indexPath.row, item.mediaTitle];
}

@end
NS_ASSUME_NONNULL_END








































#import <SJRouter/SJRouter.h>
@interface SJViewController1 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController1 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/playbackListControl/vc1";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController1 alloc] initWithNibName:@"SJViewController1" bundle:nil] animated:YES];
}

@end
