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
#import <SJUIKit/UIScrollView+SJRefreshAdd.h>

static NSString *const SJVideoListTableViewCellID = @"SJVideoListTableViewCell";

@interface SJVideoListViewController ()<UITableViewDelegate, UITableViewDataSource, SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate>

@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@property (nonatomic, strong, readonly) FilmEditingHelper *filmEditingHelper;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableArray<SJVideoModel *> *videosM;

@end

@implementation SJVideoListViewController {
    NSMutableArray<SJVideoModel *> *_videosM;
}

@synthesize indicator = _indicator;
@synthesize tableView = _tableView;

- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
   
    [self.tableView sj_exeHeaderRefreshing];

    // Do any additional setup after loading the view.
}

#pragma mark - play asset

- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell {
    [self sj_playerNeedPlayNewAssetAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSURL *URL = [NSURL URLWithString:cell.model.playURLStr];
    SJPlayModel *playModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:cell.coverImageView.tag atIndexPath:indexPath tableView:self.tableView];
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
    asset.title = @"DIY心情转盘 #手工##手工制作##卖包子喽##1块1个##卖完就撤#";
    asset.alwaysShowTitle = YES;
    
    [self playWithAsset:asset playerParentView:cell.coverImageView];
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
        
        // 开启剪辑功能[截屏/GIF/导出]
        _player.enableFilmEditing = YES;
        [_player.filmEditingConfig config:self.filmEditingHelper.filmEditingConfig];
    }
    
    _player.URLAsset = asset;
    
    [playerParentView addSubview:_player.view]; // 将播放器添加到父视图中
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

@synthesize filmEditingHelper = _filmEditingHelper;
- (FilmEditingHelper *)filmEditingHelper {
    if ( _filmEditingHelper ) return _filmEditingHelper;
    _filmEditingHelper = [[FilmEditingHelper alloc] initWithViewController:self];
    return _filmEditingHelper;
}

#pragma mark -

- (void)_setupViews {
    _videosM = [NSMutableArray array];
    
    self.title = @"TableView";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    /**
     全屏返回手势
     显示模式目前有两种: 1. 使用快照(截屏); 2. 使用原始视图(vc.view);
     SJPreViewDisplayMode_Origin 使用原始视图, 表示当手势返回时, 底部视图使用前一个vc的view;
     如下:
     */
    self.sj_displayMode = SJPreViewDisplayMode_Origin;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
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

#pragma mark -

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
    
    /// 配置刷新
    __weak typeof(self) _self = self;
    [_tableView sj_setupRefreshingWithPageSize:20 beginPageNum:1 refreshingBlock:^(UITableView *tableView, NSInteger pageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.indicator startAnimating];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            // prepare test data.
            NSArray<SJVideoModel *> *videos = [SJVideoModel videoModelsWithTapActionDelegate:self size:tableView.sj_pageSize];
#ifdef SJ_MAC
            sleep(1); // #warning 模拟网络延时
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( pageNum == tableView.sj_beginPageNum ) {
                    [self.videosM removeAllObjects];
                    [self.player stopAndFadeOut];
                    self.player = nil;
                }
                [self.videosM addObjectsFromArray:videos];
                [self.tableView reloadData];
                [self.indicator stopAnimating];
                [self.tableView sj_endRefreshingWithItemCount:videos.count];
            });
        });
    }];
    return _tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoPlayerURLAsset *asset = nil;
    if ( [tableView.sj_currentPlayingIndexPath isEqual:indexPath] ) {
        asset = self.player.URLAsset;
    }
    DemoPlayerViewController *vc = [[DemoPlayerViewController alloc] initWithVideo:_videosM[indexPath.row] asset:asset];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videosM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoListTableViewCell heightWithVideo:_videosM[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoListTableViewCell * cell = (SJVideoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SJVideoListTableViewCellID forIndexPath:indexPath];
    cell.model = _videosM[indexPath.row];
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
