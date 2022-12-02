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
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>
#import <Masonry/Masonry.h>

@implementation UIAlertController (SJAdditions)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
 
- (BOOL)shouldAutorotate {
    return NO;
}
@end


@interface SJRotationModeDemoViewController2 ()<UITableViewDelegate, UITableViewDataSource, SJVideoTableViewCellDelegate>
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
 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self.tableView sj_exeHeaderRefreshingAnimated:YES];
}

- (void)coverItemWasTapped:(SJVideoTableViewCell *)cell {
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        _player.allowHorizontalTriggeringOfPanGesturesInCells = YES;
        [self _observePlayerViewAppearState];
        [self _addTestEdgeItemsToPlayer];
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    SJVideoCellViewModel *item = _viewModel.tableItems[indexPath.row];
    SJPlayModel *playModel = [SJPlayModel playModelWithTableView:_tableView indexPath:indexPath superviewSelector:NSSelectorFromString(@"coverImageView")];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:item.url playModel:playModel];
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
    [SJVideoTableViewCell registerWithTableView:_tableView];
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
        NSMutableArray<SJVideoCellViewModel *> *m = [NSMutableArray arrayWithCapacity:tableView.sj_pageSize];
        for ( int i = 0; i < tableView.sj_pageSize ; ++ i ) {
            SJVideoModel *model = [SJVideoModel testItem];
            [m addObject:[[SJVideoCellViewModel alloc] initWithItem:model]];
        }
        
        if ( requestPageNum == tableView.sj_beginPageNum ) {
            [self.viewModel removeAllItems];
            [self.player stop];
            [self.tableView sj_removeCurrentPlayerView];
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
    return [SJVideoTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJVideoTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _viewModel.tableItems[indexPath.row];
    cell.delegate = self;
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

- (BOOL)shouldAutorotate {
    return NO;
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
