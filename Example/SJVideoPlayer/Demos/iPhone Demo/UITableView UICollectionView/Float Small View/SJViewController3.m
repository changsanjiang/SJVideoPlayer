//
//  SJViewController3.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController3.h"
#import "SJRotationMode2ViewModel.h"
#import <SJUIKit/SJUIKit.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import "SJViewController4.h"

@interface SJViewController3 ()<UITableViewDelegate, UITableViewDataSource, SJMediaTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, nullable) SJRotationMode2ViewModel *viewModel;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@property (nonatomic) BOOL pauseWhenViewDidDisappear;
@end

@implementation SJViewController3
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self.tableView sj_exeHeaderRefreshingAnimated:YES];
}

- (void)tappedCoverOnTheTableViewCell:(SJMediaTableViewCell *)cell {
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        [self _setupFloatSmallViewControllerOfPlayer];
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    SJMediaTableViewModel *item = _viewModel.tableItems[indexPath.row];
    SJPlayModel *cellModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:item.coverTag atIndexPath:indexPath tableView:_tableView];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:item.url playModel:cellModel];
}

- (void)_setupFloatSmallViewControllerOfPlayer {
    __weak typeof(self) _self = self;
    // 开启小浮窗(当播放器视图滑动消失时, 显示小浮窗视图)
    self.player.floatSmallViewController.enabled = YES;
    self.player.pauseWhenScrollDisappeared = NO;
    
    // 单击小浮窗时的回调
    self.player.floatSmallViewController.singleTappedOnTheFloatViewExeBlock = ^(id<SJFloatSmallViewControllerProtocol>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.pauseWhenViewDidDisappear = NO;
        [controller dismissFloatView];
        [self.navigationController pushViewController:[[SJViewController4 alloc] initWithAsset:self.player.URLAsset] animated:YES];
    };
    
    // 双击小浮窗时的回调
    self.player.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock = ^(id<SJFloatSmallViewControllerProtocol>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.player.playStatus == SJVideoPlayerPlayStatusPlaying )
            [self.player pause];
        else
            [self.player play];
    };
    
    // 其他设置请前往头文件`SJFloatSmallViewControllerDefines.h`查看
}

- (void)testPushAction:(SJEdgeControlButtonItem *)item {
    [_player rotate:SJOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        [self.navigationController pushViewController:[[SJViewController3 alloc] initWithNibName:@"SJViewController3" bundle:nil] animated:YES];
    }];
}

#pragma mark -
- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _viewModel = [SJRotationMode2ViewModel new];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.offset(UIScreen.mainScreen.bounds.size.width);
    }];
    [SJMediaTableViewCell registerWithTableView:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    
    __weak typeof(self) _self = self;
    [_tableView sj_setupRefreshingWithPageSize:20 beginPageNum:1 refreshingBlock:^(UITableView *tableView, NSInteger requestPageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        // 模拟数据
        NSMutableArray<SJMediaTableViewModel *> *m = [NSMutableArray arrayWithCapacity:tableView.sj_pageSize];
        for ( int i = 0; i < tableView.sj_pageSize ; ++ i ) {
            SJMeidaItemModel *model = [SJMeidaItemModel testItem];
            [m addObject:[[SJMediaTableViewModel alloc] initWithItem:model]];
        }
        
        if ( requestPageNum == tableView.sj_beginPageNum ) {
            [self.viewModel removeAllItems];
        }
        
        [self.viewModel addItems:m];
        [self.tableView reloadData];
        [self.tableView sj_endRefreshingWithItemCount:m.count];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.tableItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _viewModel.tableItems[indexPath.row].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJMediaTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJMediaTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _viewModel.tableItems[indexPath.row];
    cell.delegate = self;
} 

#pragma mark -

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
    _pauseWhenViewDidDisappear = YES; ///< resume
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ( _pauseWhenViewDidDisappear == YES )
        [self.player pause];
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


#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJViewController3 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController3 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/scrollView/floatSmallView";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController3 alloc] initWithNibName:@"SJViewController3" bundle:nil] animated:YES];
}

@end

