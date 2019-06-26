//
//  SJViewController1.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController1.h"
#import "SJTableViewCell1.h"
#import "SJMeidaItemModel.h"
#import <SJUIKit/SJUIKit.h>
#import <SJPlaybackListController/SJPlaybackListController.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import "SJRemoteCommandHandler.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *const SJTableViewCell1ID = @"SJTableViewCell1";

@interface SJViewController1 ()<UITableViewDelegate, UITableViewDataSource, SJPlaybackListControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *playerContainerVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@property (nonatomic, strong, readonly) SJPlaybackListController *listController;;
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
    [self.listController playPreviousMedia];
}

- (IBAction)playNextMedia:(id)sender {
    [self.listController playNextMedia];
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
        [self.listController playPreviousMedia];
    };
    
    SJRemoteCommandHandler.shared.nextCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.listController playNextMedia];
    };
    
    SJRemoteCommandHandler.shared.seekToTimeCommandHandler = ^(id<SJRemoteCommandHandler>  _Nonnull handler, NSTimeInterval secs) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player seekToTime:secs completionHandler:nil];
    };
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.listController playAtIndex:indexPath.row];
}

- (void)listController:(id<SJPlaybackListController>)listController needToPlayMedia:(id<SJMediaInfo>)media {
    SJMeidaItemModel *item = (id)media;
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        [self _addListControlItemsToPlayer];
        [_playerContainerVIew addSubview:_player.view];
        [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        __weak typeof(self) _self = self;
        _player.playDidToEndExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self.listController currentMediaFinishedPlaying];
        };
        
        _player.pauseWhenAppDidEnterBackground = NO; ///< 开启后台播放
    }
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:item.URL];
    _player.URLAsset.title = item.mediaTitle;
    _player.playTimeDidChangeExeBlok = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
        NSDictionary *info =
        @{MPMediaItemPropertyTitle:item.mediaTitle,
          MPMediaItemPropertyMediaType:@(MPMediaTypeAny),
          MPNowPlayingInfoPropertyElapsedPlaybackTime:@(videoPlayer.currentTime),
          MPMediaItemPropertyPlaybackDuration:@(videoPlayer.totalTime),
          MPNowPlayingInfoPropertyPlaybackRate:@(videoPlayer.rate)};
        [SJRemoteCommandHandler.shared updateNowPlayingInfo:info];
    };

    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[listController indexForMediaId:media.id] inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)listController:(id<SJPlaybackListController>)listController needToReplayCurrentMedia:(id<SJMediaInfo>)media {
    [_player replay];
}

- (void)currentMediaForListControllerIsRemoved:(id<SJPlaybackListController>)listController {}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    
    _listController = [SJPlaybackListController new];
    _listController.delegate = self;
    
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
        NSMutableArray<SJMeidaItemModel *> *m = [NSMutableArray arrayWithCapacity:tableView.sj_pageSize];
        for ( int i = 0; i < tableView.sj_pageSize ; ++ i ) {
            SJMeidaItemModel *model = [SJMeidaItemModel testItem];
            [m addObject:model];
        }
        
        if ( requestPageNum == tableView.sj_beginPageNum ) {
            [self.listController removeAllMedias];
            self.player = nil;
        }
        
        [self.listController addMedias:(id)m];
        [self.tableView reloadData];
        [self.tableView sj_endRefreshingWithItemCount:m.count];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listController.medias.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:SJTableViewCell1ID forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJTableViewCell1 *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SJMeidaItemModel *item = [self.listController mediaAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld: %@", indexPath.row, item.mediaTitle];
}

#pragma mark -
- (void)_addListControlItemsToPlayer {
//    _player.defaultEdgeControlLayer.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    
    SJEdgeControlButtonItem *nextItem = [[SJEdgeControlButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"] target:_listController action:@selector(playNextMedia) tag:1000];
    [_player.defaultEdgeControlLayer.bottomAdapter insertItem:nextItem frontItem:SJEdgeControlLayerBottomItem_Play];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];

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
