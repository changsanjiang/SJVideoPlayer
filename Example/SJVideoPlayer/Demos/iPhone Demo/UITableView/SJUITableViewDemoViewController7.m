//
//  SJUITableViewDemoViewController7.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJUITableViewDemoViewController7.h"
#import <SJUIKit/SJPageViewController.h>
#import <SJUIKit/SJPageMenuItemView.h>
#import <SJUIKit/SJPageMenuBar.h>
#import <Masonry/Masonry.h>
#import "SJTopView.h"
#import "SJSourceURLs.h"

#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import <SJFullscreenPopGesture/SJFullscreenPopGesture.h>
 
@interface SJUITableViewDemoViewController7 ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource, SJPageMenuBarDelegate, SJTopViewDelegate>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) SJTopView *topView;
@property (nonatomic, strong) SJVideoPlayer *player;

@property (nonatomic, strong) SJPageViewController *pageViewController;
@property (nonatomic, strong) UIView *pageHeaderView;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar;
@end

@implementation SJUITableViewDemoViewController7

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    // 模拟数据
    NSMutableArray<SJPageMenuItemView *> *m = [NSMutableArray arrayWithCapacity:99];
    for ( int i = 0 ; i < 99 ; ++ i  ) {
        SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
        view.text = @[@"从前", @"有", @"99", @"座", @"灵剑山AAAAAAAAAA"][i % 5];
        view.font = [UIFont boldSystemFontOfSize:18];
        [m addObject:view];
    }
    
    self.pageMenuBar.itemViews = m;
    [self.pageViewController reloadPageViewController];
    [self.pageMenuBar scrollToItemAtIndex:4 animated:NO];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

- (void)backButtonWasTapped {
    [self.navigationController popViewControllerAnimated:YES];
}
 
- (void)playButtonWasTapped:(SJTopView *)bar {
    [_player play];
}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 全屏手势开始触发的时候, 禁止自动旋转
    self.sj_viewWillBeginDragging = ^(SJUITableViewDemoViewController7 *vc) {
        vc.player.rotationManager.disabledAutorotation = YES;
    };
    // 恢复
    self.sj_viewDidEndDragging = ^(SJUITableViewDemoViewController7 *vc) {
        vc.player.rotationManager.disabledAutorotation = NO;
    };

    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(3)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    _pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    _pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    _pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth;
    _pageMenuBar.delegate = self;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
     
    _topView = [SJTopView.alloc initWithFrame:CGRectZero];
    _topView.delegate = self;
    _topView.hidden = YES;
    [self.view addSubview:self.topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
    }];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton addTarget:self action:@selector(backButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImage:SJVideoPlayerSettings.commonSettings.backBtnImage forState:UIControlStateNormal];
    [self.view addSubview:_backButton];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.topView.contentView);
        make.width.equalTo(self.topView.contentView.mas_height);
    }];
}
 
#pragma mark - Page View Controller

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return self.pageMenuBar.numberOfItems;
}

- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return UITableViewController.new;
}

- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
    return SJPageViewControllerHeaderModePinnedToTop;
}

// 添加`player.view`和`pageMenuBar`到 pageHeaderView 中
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController {
    if ( _player == nil ) {
        _player = SJVideoPlayer.player;
        _player.defaultEdgeControlLayer.hiddenBackButtonWhenOrientationIsPortrait = YES; // 竖屏时, 隐藏返回按钮, 显示我们自己的返回按钮(self.backButton)
        _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 startPosition:10];
        __weak typeof(self) _self = self;
        _player.shouldTriggerRotation = ^BOOL(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return NO;
            if ( player.isPlaying ) return YES;
            if ( player.isFullScreen ) return YES;
            return self.topView.isHidden; // 竖屏时, topView显示后, 禁止旋转
        };
        _player.rotationObserver.rotationDidStartExeBlock = ^(id<SJRotationManager>  _Nonnull mgr) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.backButton.hidden = YES; // 开始旋转的时候, 隐藏我们自己的返回按钮
        };
        _player.rotationObserver.rotationDidEndExeBlock = ^(id<SJRotationManager>  _Nonnull mgr) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.backButton.hidden = NO; // 完成旋转的时候, 显示我们自己的返回按钮
        };
        _player.playbackObserver.timeControlStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(player.isPaused ? @"已暂停" : @"正在播放中"); // 提示
                make.textColor(UIColor.whiteColor);
            }] duration:-1];
            
            // 播放器处于播放中时, 纠正`pageHeaderView`的位置
            if ( player.isPlaying ) {
                UITableViewController *tableViewController = self.pageViewController.focusedViewController;
                UIView *pageHeaderView = self.pageViewController.headerView;
                UITableView *tableView = tableViewController.tableView;
                CGPoint offset = tableView.contentOffset;
                CGRect rect = [pageHeaderView convertRect:pageHeaderView.bounds toView:tableView.superview];
                offset.y += rect.origin.y;
                // 加个动画, 顺畅一些
                [UIView animateWithDuration:0.4 animations:^{
                    CGRect frame = pageHeaderView.frame;
                    frame.origin.y -= rect.origin.y;
                    pageHeaderView.frame = frame;
                    [tableViewController.tableView setContentOffset:offset animated:NO];
                }];
            }
        };
    }
    
    if ( _pageHeaderView == nil ) {
        _pageHeaderView = [UIView.alloc initWithFrame:CGRectZero];
        _pageHeaderView.backgroundColor = UIColor.blackColor;
        [_pageHeaderView addSubview:_player.view];
        [_pageHeaderView addSubview:_pageMenuBar];
     
        CGFloat topMargin = 20;
        if (@available(iOS 11.0, *)) {
            topMargin = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
        }
        CGFloat width = UIApplication.sharedApplication.keyWindow.bounds.size.width;
        CGFloat playerViewHeight = width * 9 / 16.0;
        CGFloat menuBarHeight = 49;
        CGFloat pageHeaderViewHeight = topMargin + playerViewHeight + menuBarHeight;
        _pageHeaderView.frame   = CGRectMake(0, 0, width, pageHeaderViewHeight);
        _player.view.frame      = CGRectMake(0, topMargin, width, playerViewHeight);
        _pageMenuBar.frame      = CGRectMake(0, CGRectGetMaxY(_player.view.frame), width, menuBarHeight);
    }
    return _pageHeaderView;
}

// 钉在顶部的高度
//  - 播放器处于暂停时, 只钉住49的高度, 保留`pageMenuBar`. 处于播放器中时, 保留整个`pageHeaderView`的高度
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return _player.isPaused ? (_pageMenuBar.bounds.size.height + _topView.bounds.size.height) : _pageHeaderView.bounds.size.height;
}
 
- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    [_pageMenuBar scrollInRange:range distanceProgress:progress];
}

- (void)pageViewController:(SJPageViewController *)pageViewController headerViewVisibleRectDidChange:(CGRect)visibleRect {
    CGFloat progress = 0;
    if ( _player.isPaused ) {
        /// pageHeaderView的高度
        CGFloat pageHeaderViewHeight = pageViewController.heightForHeaderBounds;
        /// 在顶部固定时的高度
        CGFloat pinnedHeight = pageViewController.heightForHeaderPinToVisibleBounds;
        /// 设置导航栏透明度
        progress = 1 - (visibleRect.size.height - pinnedHeight) / (pageHeaderViewHeight - pinnedHeight);
    }
    _topView.hidden = progress < 0.99;
}

#pragma mark - Page Menu Bar

- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSUInteger)index {
    if ( [_pageViewController isViewControllerVisibleAtIndex:index] ) return;
    [_pageViewController setViewControllerAtIndex:index];
}

#pragma mark -

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
