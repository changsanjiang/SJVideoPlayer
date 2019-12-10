//
//  SJRotationModeDemoViewController2.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJRotationModeDemoViewController2.h"
#import "SJRotationMode2ViewModel.h"
#import <SJUIKit/SJUIKit.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>

#import "SJRotationManager.h"

@interface SJRotationModeDemoViewController2 ()<UITableViewDelegate, UITableViewDataSource, SJMediaTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, nullable) SJRotationMode2ViewModel *viewModel;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation SJRotationModeDemoViewController2
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
}

- (void)testPushAction:(SJEdgeControlButtonItem *)item {
    [_player rotate:SJOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        [self.navigationController pushViewController:[[SJRotationModeDemoViewController2 alloc] initWithNibName:@"SJRotationModeDemoViewController2" bundle:nil] animated:YES];
    }];

}

- (void)testAlertItem:(SJEdgeControlButtonItem *)item {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TEST ALERT" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:^(UIAlertAction * _Nonnull action) {}]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)viewSafeAreaInsetsDidChange {
    NSLog(@"A: %@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    [super viewSafeAreaInsetsDidChange];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self.tableView sj_exeHeaderRefreshingAnimated:YES];
}

- (void)tappedCoverOnTheTableViewCell:(SJMediaTableViewCell *)cell {
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        _player.fastForwardViewController.enabled = YES;
        _player.allowHorizontalTriggeringOfPanGesturesInCells = YES;
        [self _observePlayerViewAppearState];
        [self _addTestEdgeItemsToPlayer];
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    SJMediaTableViewModel *item = _viewModel.tableItems[indexPath.row];
    SJPlayModel *cellModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:item.coverTag atIndexPath:indexPath tableView:_tableView];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:item.url playModel:cellModel];
}

- (void)_observePlayerViewAppearState {
    _player.playerViewWillAppearExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
#ifdef DEBUG
        NSLog(@"- playerViewWillAppear -");
#endif
    };
    
    _player.playerViewWillDisappearExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
#ifdef DEBUG
        NSLog(@"- playerViewWillDisappear -");
#endif
    };
}

- (void)_addTestEdgeItemsToPlayer {
    SJEdgeControlButtonItem *pushItem = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"Push");
        make.textColor([UIColor greenColor]);
        make.font([UIFont boldSystemFontOfSize:20]);
    }] target:self action:@selector(testPushAction:) tag:1000];
    
    [_player.defaultEdgeControlLayer.rightAdapter addItem:pushItem];
    
    SJEdgeControlButtonItem *alertItem = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"Alert");
        make.textColor([UIColor greenColor]);
        make.font([UIFont boldSystemFontOfSize:20]);
    }] target:self action:@selector(testAlertItem:) tag:1001];
    alertItem.insets = SJEdgeInsetsMake(12, 0);
    [_player.defaultEdgeControlLayer.rightAdapter addItem:alertItem];
    
    [_player.defaultEdgeControlLayer.rightAdapter reload];
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

- (BOOL)shouldAutorotate {
    return NO;
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


#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJRotationModeDemoViewController2 (RouteHandler)<SJRouteHandler>

@end

@implementation SJRotationModeDemoViewController2 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/rotationMode/vc2";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJRotationModeDemoViewController2 alloc] initWithNibName:@"SJRotationModeDemoViewController2" bundle:nil] animated:YES];
}

@end



/**
 
 _player.pauseWhenScrollDisappeared = NO;            ///< 滚动消失后, 不暂停
 _player.resumePlaybackWhenScrollAppeared = NO;      ///< 滚动出现后, 如果暂停, 则不恢复播放
 _player.floatSmallViewController.enabled = YES;     ///< 开启小浮窗
 __weak typeof(self) _self = self;
 _player.floatSmallViewController.singleTappedOnTheFloatViewExeBlock =  ///< 单击小浮窗执行的block
 ^(id<SJFloatSmallViewController>  _Nonnull controller) {
 __strong typeof(_self) self = _self;
 if ( !self ) return ;
 [controller dismissFloatView];
 //            [self.navigationController pushViewController:[[ViewControllerContinuePlaying alloc] initWithAsset:self.player.URLAsset] animated:YES];
 };
 _player.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock = ///< 双击小浮窗执行的block
 ^(id<SJFloatSmallViewController>  _Nonnull controller) {
 __strong typeof(_self) self = _self;
 if ( !self ) return ;
 if ( self.player.playStatus == SJVideoPlayerPlayStatusPlaying )
 [self.player pause];
 else
 [self.player play];
 };
 */
