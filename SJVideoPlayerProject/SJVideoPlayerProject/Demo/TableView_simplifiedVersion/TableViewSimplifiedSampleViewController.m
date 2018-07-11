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

static NSString *const SimplifiedSampleTableViewCellID = @"SimplifiedSampleTableViewCell";

@interface TableViewSimplifiedSampleViewController ()<UITableViewDataSource, UITableViewDelegate, SJPlayerAutoplayDelegate, SimplifiedSampleTableViewCellDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videos;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation TableViewSimplifiedSampleViewController

@synthesize tableView = _tableView;
@synthesize indicator = _indicator;

- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.indicator startAnimating];
    // prepare test data.
    self.tableView.alpha = 0.001;
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // some test data
        NSArray<SJVideoModel *> *videos = [SJVideoModel videoModelsWithTapActionDelegate:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.videos = videos;
            [self.tableView reloadData];
            [self.indicator stopAnimating];
            // fade in
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.alpha = 1;
            }];
            
            [self.tableView sj_enableAutoplayWithConfig:[SJPlayerAutoplayConfig configWithPlayerSuperviewTag:101 autoplayDelegate:self]];
            
            [self.tableView sj_needPlayNextAsset];
            
        });
    });
        
    // Do any additional setup after loading the view.
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    [self clickedPlayButtonOnTheTabCell:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)clickedPlayButtonOnTheTabCell:(SimplifiedSampleTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSURL *URL = [NSURL URLWithString:_videos[indexPath.row].playURLStr];
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

        // 点击返回按钮执行的block
        __weak typeof(self) _self = self;
        _player.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.navigationController popViewControllerAnimated:YES];
        };
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
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIActivityIndicatorView *)indicator {
    if ( _indicator ) return _indicator;
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.csj_size = CGSizeMake(80, 80);
    _indicator.center = self.view.center;
    _indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
    _indicator.clipsToBounds = YES;
    _indicator.layer.cornerRadius = 6;
    [self.view addSubview:_indicator];
    return _indicator;
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
