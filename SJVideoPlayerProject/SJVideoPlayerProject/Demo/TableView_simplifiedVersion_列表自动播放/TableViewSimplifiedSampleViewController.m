//
//  TableViewSimplifiedSampleViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/7/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TableViewSimplifiedSampleViewController.h"
#import "SimplifiedSampleTableViewCell.h"
#import <Masonry.h>
#import <SJUIFactory/UIView+SJUIFactory.h>
#import <SJUIFactory/SJUIFactory.h>
#import "SJVideoModel.h"
#import <UIScrollView+ListViewAutoplaySJAdd.h>
#import "SJVideoPlayer.h"
#import <SJUIKit/UIScrollView+SJRefreshAdd.h>

static NSString *const SimplifiedSampleTableViewCellID = @"SimplifiedSampleTableViewCell";

@interface TableViewSimplifiedSampleViewController ()<UITableViewDataSource, UITableViewDelegate, SJPlayerAutoplayDelegate, SimplifiedSampleTableViewCellDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videos;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation TableViewSimplifiedSampleViewController
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    self.videos = [SJVideoModel testModelsWithTapActionDelegate:nil size:20];
    
    // 配置列表自动播放
    [self.tableView sj_enableAutoplayWithConfig:[SJPlayerAutoplayConfig configWithPlayerSuperviewTag:101 autoplayDelegate:self]];
    [self.tableView sj_needPlayNextAsset];
    
    // Do any additional setup after loading the view.
}

- (void)clickedPlayButtonOnTheTabCell:(SimplifiedSampleTableViewCell *)cell {
    [self sj_playerNeedPlayNewAssetAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *URL = [NSURL URLWithString:_videos[indexPath.row].playURLStr];
    SimplifiedSampleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    SJPlayModel *playModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:cell.backgroundImageView.tag atIndexPath:indexPath tableView:self.tableView];
    
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
    asset.title = @"DIY心情转盘 #手工##手工制作##卖包子喽##1块1个##卖完就撤#";
    asset.alwaysShowTitle = YES;
    [self playWithAsset:asset playerParentView:cell.backgroundImageView];
}

- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView {
    // 全屏播放时无需重新创建播放器, 只需设置`asset`即可
    // 如果播放器不是全屏, 就重新创建一个播放器
    if ( !_player || !_player.isFullScreen ) {
        [_player stopAndFadeOut]; // 让旧的播放器淡出
        _player = [SJVideoPlayer player]; // 创建一个新的播放器
        _player.generatePreviewImages = YES; // 生成预览缩略图, 大概20张
        // fade in(淡入)
        _player.view.alpha = 0.001;
        [UIView animateWithDuration:0.5 animations:^{
            self.player.view.alpha = 1;
        }];
    }

    _player.URLAsset = asset;

    [playerParentView addSubview:_player.view]; // 将播放器添加到父视图中
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
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

- (void)_setupViews {
    self.title = @"SimplifiedSample";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UITableView *)tableView {
    if ( _tableView ) return _tableView;
    _tableView = [SJUITableViewFactory tableViewWithStyle:UITableViewStylePlain backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleNone showsVerticalScrollIndicator:YES delegate:self dataSource:self];
    [_tableView registerClass:NSClassFromString(SimplifiedSampleTableViewCellID) forCellReuseIdentifier:SimplifiedSampleTableViewCellID];
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SimplifiedSampleTableViewCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimplifiedSampleTableViewCell * cell = (SimplifiedSampleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SimplifiedSampleTableViewCellID forIndexPath:indexPath];
    cell.backgroundImageView.image = [UIImage imageNamed:_videos[indexPath.row].coverURLStr];
    cell.delegate = self;
    return cell;
}
@end
