//
//  SJVideoListViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoListViewController.h"
#import <SJUIFactory.h>
#import <Masonry.h>
#import "SJVideoListTableViewCell.h"
#import "SJVideoModel.h"
#import "SJVideoPlayer.h"
#import <UIView+SJUIFactory.h>
#import "DemoPlayerViewController.h"
#import "YYTapActionLabel.h"
#import "FilmEditingHelper.h"
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>
#import <UIScrollView+ListViewAutoplaySJAdd.h>

static NSString *const SJVideoListTableViewCellID = @"SJVideoListTableViewCell";

@interface SJVideoListViewController ()<UITableViewDelegate, UITableViewDataSource, SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate, SJPlayerAutoplayDelegate>

@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@property (nonatomic, strong, readonly) FilmEditingHelper *filmEditingHelper;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *playedIndexPath;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videos;

@property (nonatomic, strong, readonly) UIView *midLine;

@end

@implementation SJVideoListViewController

@synthesize indicator = _indicator;
@synthesize tableView = _tableView;
@synthesize midLine = _midLine;

- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     全屏返回手势
     显示模式目前有两种: 1. 使用快照(截屏); 2. 使用原始视图(vc.view);
     SJPreViewDisplayMode_Origin 使用原始视图, 表示当手势返回时, 底部视图使用前一个vc的view;
     如下:
     */
    self.sj_displayMode = SJPreViewDisplayMode_Origin;
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // setup views
    [self _videoListSetupViews];
    
    [self.indicator startAnimating];
    // prepare test data.
    self.tableView.alpha = 0.001;
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // some test data
        NSArray<SJVideoModel *> *videos = [SJVideoModel videoModelsWithTapActionDelegate:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.videos = videos;
            [self.tableView reloadData];
            [self.indicator stopAnimating];
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.alpha = 1;
            }];
            
            // 开启自动播放
            [self.tableView sj_enableAutoplayWithConfig:[SJPlayerAutoplayConfig configWithPlayerSuperviewTag:101 autoplayDelegate:self]];
            
            // play asset
            [self.tableView sj_needPlayNextAsset];
            
        });
    });

    // Do any additional setup after loading the view.
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    self.playedIndexPath = indexPath;
    SJVideoListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSURL *URL = [NSURL URLWithString:cell.model.playURLStr];
    SJPlayModel *playModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:cell.coverImageView.tag atIndexPath:indexPath tableView:self.tableView];
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
    
    asset.title = @"DIY心情转盘 #手工##手工制作##卖包子喽##1块1个##卖完就撤#";
    asset.alwaysShowTitle = YES;
    
    [self playWithAsset:asset playerParentView:cell.coverImageView];
}

- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView {
    
    // 如果播放器不是全屏, 就重新创建一个播放器
    // 全屏播放时无需重新创建播放器, 只需设置`asset`即可
    if ( !_player || !_player.isFullScreen ) {
        [_player stopAndFadeOut]; // 让旧的播放器淡出
        
        _player = [SJVideoPlayer player]; // 创建一个新的播放器
        _player.generatePreviewImages = YES; // 生成预览缩略图, 大概20张
        [playerParentView addSubview:_player.view]; // 将播放器添加到父视图中
        [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
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
        
        _player.enableFilmEditing = YES;
        [_player.filmEditingConfig config:self.filmEditingHelper.filmEditingConfig];
    }
    
    _player.URLAsset = asset;
}

@synthesize filmEditingHelper = _filmEditingHelper;
- (FilmEditingHelper *)filmEditingHelper {
    if ( _filmEditingHelper ) return _filmEditingHelper;
    _filmEditingHelper = [[FilmEditingHelper alloc] initWithViewController:self];
    return _filmEditingHelper;
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

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView {
    [self sj_playerNeedPlayNewAssetAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoPlayerURLAsset *asset = nil;
    if ( [self.playedIndexPath isEqual:indexPath] ) {
        asset = self.player.URLAsset;
    }
    DemoPlayerViewController *vc = [[DemoPlayerViewController alloc] initWithVideo:self.videos[indexPath.row] asset:asset];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -

- (void)_videoListSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _midLine = [SJUIViewFactory viewWithBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:self.midLine];
    [self.midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.centerY.offset(0);
        make.height.offset(2);
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
    [_tableView registerClass:NSClassFromString(SJVideoListTableViewCellID) forCellReuseIdentifier:SJVideoListTableViewCellID];
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoListTableViewCell heightWithVideo:_videos[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoListTableViewCell * cell = (SJVideoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SJVideoListTableViewCellID forIndexPath:indexPath];
    cell.model = _videos[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - other
- (void)attributedString:(NSAttributedString *)attrStr tappedStr:(NSAttributedString *)tappedStr {
    UIViewController *vc = [[self class] new];
    vc.title = tappedStr.string;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tappedOtherPlacesOfAttributedString:(NSAttributedString *)attrStr {
    SJVideoModel *model = attrStr.object;
    SJVideoPlayerURLAsset *asset = nil;
    if ( [self.player.assetURL.absoluteString isEqualToString:model.playURLStr] ) {
        asset = self.player.URLAsset;
    }
    DemoPlayerViewController *vc = [[DemoPlayerViewController alloc] initWithVideo:model asset:asset];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
