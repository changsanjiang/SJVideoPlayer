//
//  TableViewAutoPlayViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/7/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TableViewAutoPlayViewController.h"
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
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>

#import <objc/message.h>
#import <NSObject+SJObserverHelper.h>

static NSString *const SJVideoListTableViewCellID = @"SJVideoListTableViewCell";

@interface TableViewAutoPlayViewController ()<UITableViewDelegate, UITableViewDataSource, SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@property (nonatomic, strong, readonly) FilmEditingHelper *filmEditingHelper;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *playedIndexPath;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videos;

@property (nonatomic, strong, readonly) UIView *midLine;

@end

@implementation TableViewAutoPlayViewController

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
    
    NSURL *URL = [NSURL URLWithString:cell.model.playURLStr];
    //    URL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    SJPlayModel *playModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:playerParentView.tag atIndexPath:self.playedIndexPath tableView:self.tableView];
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
    
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
    
    [self.view addSubview:self.midLine];
    [_midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.centerY.offset(0);
        make.height.offset(3);
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
    return self.view.frame.size.height;
    return [SJVideoListTableViewCell heightWithVideo:_videos[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoListTableViewCell * cell = (SJVideoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SJVideoListTableViewCellID forIndexPath:indexPath];
    cell.model = _videos[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (UIView *)midLine {
    if ( _midLine ) return _midLine;
    _midLine = [SJUIViewFactory viewWithBackgroundColor:[UIColor greenColor]];
    return _midLine;
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


#pragma mark -

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
#ifdef DEBUG
    NSLog(@"%d - %s - %d", (int)__LINE__, __func__, decelerate);
#endif
    if ( !decelerate ) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    NSLog(@"%@", self.tableView.visibleCells);
    
    SJUITableViewCellPlayModel *playModel = (id)self.videoPlayerHelper.videoPlayer.URLAsset.playModel;
    if ( [self.tableView.indexPathsForVisibleRows containsObject:playModel.indexPath] ) return;

    
    /// 注意一下 ios 11之后的
    CGFloat midLine = floor((CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.top) * 0.5);
    
    NSInteger count = self.tableView.visibleCells.count;
    NSInteger half = (NSInteger)(count * 0.5);
    NSArray<UITableViewCell *> *half_l = [self.tableView.visibleCells subarrayWithRange:NSMakeRange(0, half)];
    NSArray<UITableViewCell *> *half_r = [self.tableView.visibleCells subarrayWithRange:NSMakeRange(half, count - half)];
    
    NSLog(@"half_l - %@", half_l);
    NSLog(@"half_r - %@", half_r);
    
    __block UITableViewCell *cell_l = nil;
    __block UIView *half_l_view = nil;
    [half_l enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *superview = [obj viewWithTag:101];
        if ( !superview ) return;
        *stop = YES;
        cell_l = obj;
        half_l_view = superview;
    }];
    
    __block UITableViewCell *cell_r = nil;
    __block UIView *half_r_view = nil;
    [half_r enumerateObjectsUsingBlock:^(UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *superview = [obj viewWithTag:101];
        if ( !superview ) return;
        *stop = YES;
        cell_r = obj;
        half_r_view = superview;
    }];
    
    if ( half_l_view && !half_r_view ) {
        [self clickedPlayOnTabCell:(id)cell_l playerParentView:half_l_view];
    }
    else if ( half_r_view && !half_l_view ) {
        [self clickedPlayOnTabCell:(id)cell_r playerParentView:half_r_view];
    }
    else {
        /// 距离中线的位置
        CGRect half_l_rect = [half_l_view.superview convertRect:half_l_view.frame toView:self.tableView.superview];
        CGRect half_r_rect = [half_r_view.superview convertRect:half_r_view.frame toView:self.tableView.superview];
        
        NSLog(@"%f - %f - %f", midLine, ABS(CGRectGetMaxY(half_l_rect) - midLine), ABS(CGRectGetMinY(half_r_rect) - midLine));
        
        if ( ABS(CGRectGetMaxY(half_l_rect) - midLine) < ABS(CGRectGetMinY(half_r_rect) - midLine) ) {
            [self clickedPlayOnTabCell:(id)cell_l playerParentView:half_l_view];
        }
        else {
            [self clickedPlayOnTabCell:(id)cell_r playerParentView:half_r_view];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

@end
