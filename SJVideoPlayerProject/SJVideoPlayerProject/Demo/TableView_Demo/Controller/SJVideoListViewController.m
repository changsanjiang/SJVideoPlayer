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
#import "SJVideoPlayerHelper.h"
#import <UIView+SJUIFactory.h>
#import "DemoPlayerViewController.h"
#import "YYTapActionLabel.h"
#import "FilmEditingHelper.h"
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>

static NSString *const SJVideoListTableViewCellID = @"SJVideoListTableViewCell";

@interface SJVideoListViewController ()<UITableViewDelegate, UITableViewDataSource, SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@property (nonatomic, strong, readonly) FilmEditingHelper *filmEditingHelper;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *playedIndexPath;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videos;

@end

@implementation SJVideoListViewController

@synthesize indicator = _indicator;
@synthesize tableView = _tableView;

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
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
        });
    });
    
    // Do any additional setup after loading the view.
}

// please lazy load
@synthesize videoPlayerHelper = _videoPlayerHelper;
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    _videoPlayerHelper.enableFilmEditing = YES;
    _videoPlayerHelper.filmEditingConfig = self.filmEditingHelper.filmEditingConfig;
    return _videoPlayerHelper;
}

@synthesize filmEditingHelper = _filmEditingHelper;
- (FilmEditingHelper *)filmEditingHelper {
    if ( _filmEditingHelper ) return _filmEditingHelper;
    _filmEditingHelper = [[FilmEditingHelper alloc] initWithViewController:self];
    return _filmEditingHelper;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.videoPlayerHelper.vc_viewDidAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.videoPlayerHelper.vc_viewDidDisappearExeBlock();
}

- (BOOL)prefersStatusBarHidden {
    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.videoPlayerHelper.vc_preferredStatusBarStyleExeBlock();
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView {
    self.playedIndexPath = [self.tableView indexPathForCell:cell];
    SJVideoPlayerURLAsset *asset =
//    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]
    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"]
                                          beginTime:20
                                         scrollView:self.tableView
                                          indexPath:[self.tableView indexPathForCell:cell]
                                       superviewTag:playerParentView.tag];
    asset.title = @"DIY心情转盘 #手工##手工制作##卖包子喽##1块1个##卖完就撤#";
    asset.alwaysShowTitle = YES;
    
    [self.videoPlayerHelper playWithAsset:asset playerParentView:playerParentView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoPlayerURLAsset *asset = nil;
    if ( [self.playedIndexPath isEqual:indexPath] ) {
        asset = self.videoPlayerHelper.asset;
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
    if ( [self.videoPlayerHelper.currentPlayURL.absoluteString isEqualToString:model.playURLStr] ) {
        asset = self.videoPlayerHelper.asset;
    }
    DemoPlayerViewController *vc = [[DemoPlayerViewController alloc] initWithVideo:model asset:asset];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
