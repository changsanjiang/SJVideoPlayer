//
//  SJUITableViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUITableViewDemoViewController8.h"
#import <Masonry/Masonry.h>
#import "SJVideoCellViewModel.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>


@interface SJUITableViewDemoViewController8 ()<UITableViewDataSource, UITableViewDelegate, SJVideoTableViewCellDelegate, SJPlayerAutoplayDelegate>
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<SJVideoCellViewModel *> *models;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJUITableViewDemoViewController8

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    // 开启滑动自动播放
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithPlayerSuperviewSelector:NSSelectorFromString(@"coverImageView") autoplayDelegate:self];
    config.playableAreaInsets = UIEdgeInsetsMake(200, 0, 200, 0);
    [self.tableView sj_enableAutoplayWithConfig:config];
}

- (void)coverItemWasTapped:(SJVideoTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoCellViewModel *vm = _models[indexPath.row];
    
    if ( !_player ) {
        _player = [SJVideoPlayer player];
    }
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:vm.url playModel:[SJPlayModel playModelWithTableView:_tableView indexPath:indexPath superviewSelector:NSSelectorFromString(@"coverImageView")]];
    _player.URLAsset.title = vm.mediaTitle.string;
}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
        
    [SJVideoTableViewCell registerWithTableView:_tableView];
    
    // 创建测试数据
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.models = NSMutableArray.array;
        __auto_type items = [SJVideoModel testItemsWithCount:20];
        for ( SJVideoModel *item in items ) {
            [self.models addObject:[SJVideoCellViewModel.alloc initWithItem:item]];
        }
        [self.tableView reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _models.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_models[indexPath.row] height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJVideoTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _models[indexPath.row];
    cell.delegate = self;
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

@end
