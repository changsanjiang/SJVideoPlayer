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
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>
#import <UIView+SJUIFactory.h>

static NSString *const SJVideoListTableViewCellID = @"SJVideoListTableViewCell";

@interface SJVideoListViewController ()<UITableViewDelegate, UITableViewDataSource, SJVideoListTableViewCellDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videosM;
@property (nonatomic, strong) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation SJVideoListViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup views
    [self _videoListSetupViews];
    
    self.tableView.alpha = 0.001;
    
    // prepare test data.
    [self.indicator startAnimating];
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<SJVideoModel *> *videos = [SJVideoModel videoModels];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.indicator stopAnimating];
            self.videosM = videos;
            [UIView animateWithDuration:0.25 animations:^{
                self.tableView.alpha = 1;
            }];
            [self.tableView reloadData];
        });
    });
    
    // pop gesture
    self.sj_viewWillBeginDragging = ^(SJVideoListViewController *vc) {
        // video player stop roatation
        vc.videoPlayer.disableRotation = YES;
    };
    
    self.sj_viewDidEndDragging = ^(SJVideoListViewController *vc) {
        // video player enable roatation
        vc.videoPlayer.disableRotation = NO;
    };
    // Do any additional setup after loading the view.
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
#pragma mark -

- (void)_videoListSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UITableView *)tableView {
    if ( _tableView ) return _tableView;
    _tableView = [SJUITableViewFactory tableViewWithStyle:UITableViewStylePlain backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleNone showsVerticalScrollIndicator:YES delegate:self dataSource:self];
    [_tableView registerClass:NSClassFromString(SJVideoListTableViewCellID) forCellReuseIdentifier:SJVideoListTableViewCellID];
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videosM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoListTableViewCell heightWithContentHeight:_videosM[indexPath.row].contentHelper.contentHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoListTableViewCell * cell = (SJVideoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SJVideoListTableViewCellID forIndexPath:indexPath];
    cell.model = _videosM[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark

- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView {
    // old player fade out
    [_videoPlayer stopAndFadeOut];
    
    // create new player
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.view.alpha = 0.001;
    [playerParentView addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // setting player
    __weak typeof(self) _self = self;
    _videoPlayer.rotatedScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    // Call when the control view is hidden or displayed.
    _videoPlayer.controlViewDisplayStatus = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    // fade in
    [UIView animateWithDuration:0.5 animations:^{
        _videoPlayer.view.alpha = 1;
    }];
    
    // set asset
    _videoPlayer.asset =
    [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:cell.model.playURLStr]
                                             scrollView:self.tableView
                                              indexPath:[self.tableView indexPathForCell:cell]
                                           superviewTag:playerParentView.tag];
}

- (BOOL)prefersStatusBarHidden {
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( _videoPlayer.isFullScreen ) return !_videoPlayer.controlViewDisplayed;
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 全屏播放时, 使状态栏变成白色
    if ( _videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

@end
