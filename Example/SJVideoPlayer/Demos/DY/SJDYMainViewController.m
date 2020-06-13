//
//  SJDYMainViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJDYMainViewController.h"
#import <SJUIKit/SJPageViewController.h>
#import <SJUIKit/UIViewController+SJPageViewControllerExtended.h>
#import <SJUIKit/SJPageMenuBar.h>
#import <SJUIKit/SJPageMenuItemView.h>
#import <Masonry/Masonry.h>

#import <SJFullscreenPopGesture/SJFullscreenPopGesture.h>

#import "SJDYPlaybackListViewController.h"
#import "SJDYUserHomepageViewController.h"

@interface SJDYMainViewController ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource, SJPageMenuBarDelegate, UIGestureRecognizerDelegate, SJDYPlaybackListViewControllerDelegate>
@property (nonatomic, strong, nullable) SJPageViewController *pageViewController;
@property (nonatomic, strong, nullable) SJPageMenuBar *pageMenuBar;
@property (nonatomic, strong, nullable) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong, nullable) SJDYUserHomepageViewController *homepageViewController;
@property (nonatomic) CGFloat shift;
@end

@implementation SJDYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _setupGesture];
}

- (void)_handlePan:(UIPanGestureRecognizer *)pan {
    if ( _homepageViewController == nil ) {
        _homepageViewController = SJDYUserHomepageViewController.alloc.init;
    }
    CGFloat offset = [pan translationInView:pan.view].x;

    switch ( pan.state ) {
        case UIGestureRecognizerStatePossible: break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateBegan: {
            _homepageViewController.view.frame = (CGRect){self.view.bounds.size.width, 0, self.view.bounds.size};
            _homepageViewController.view.transform = CGAffineTransformIdentity;
            _pageViewController.view.transform = CGAffineTransformIdentity;
            [self.view addSubview:_homepageViewController.view];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat rate = offset / self.view.bounds.size.width;
            _pageViewController.view.transform = CGAffineTransformMakeTranslation(self.shift * rate, 0);
            _homepageViewController.view.transform = CGAffineTransformMakeTranslation(offset, 0);
        }
            break;
        case UIGestureRecognizerStateEnded: {
            BOOL push = -offset > self.shift;
            [UIView animateWithDuration:0.25 animations:^{
                self.pageViewController.view.transform = CGAffineTransformMakeTranslation(push ? -self.shift : 0, 0);
                self.homepageViewController.view.transform = CGAffineTransformMakeTranslation(push ? -self.view.bounds.size.width : 0, 0);
            } completion:^(BOOL finished) {
                self.pageViewController.view.transform = CGAffineTransformIdentity;
                self.homepageViewController.view.transform = CGAffineTransformIdentity;
                [self.homepageViewController.view removeFromSuperview];
                if ( push ) [self.navigationController pushViewController:self.homepageViewController animated:NO];
            }];
        }
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [(SJDYPlaybackListViewController *)self.pageViewController.focusedViewController playIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.blackColor;
    self.sj_displayMode = SJPreViewDisplayModeOrigin;
    self.shift = UIScreen.mainScreen.bounds.size.width * 0.382;
    
    _pageViewController = [SJPageViewController.alloc initWithOptions:nil];
    _pageViewController.view.backgroundColor = UIColor.blackColor;
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    _pageMenuBar.backgroundColor = UIColor.clearColor;
    _pageMenuBar.delegate = self;
    _pageMenuBar.distribution = SJPageMenuBarDistributionFillEqually;
    _pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth;
    _pageMenuBar.scrollIndicatorSize = CGSizeMake(16, 2);
    _pageMenuBar.itemTintColor = [UIColor colorWithWhite:0.8 alpha:1];
    _pageMenuBar.focusedItemTintColor = [UIColor colorWithRed:0.92 green:0.05 blue:0.5 alpha:1];
    _pageMenuBar.scrollIndicatorTintColor = _pageMenuBar.focusedItemTintColor;
    
    SJPageMenuItemView *followsItemView = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
    followsItemView.font = [UIFont boldSystemFontOfSize:20];
    followsItemView.text = @"关注";
    
    SJPageMenuItemView *recommendItemView = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
    recommendItemView.font = followsItemView.font;
    recommendItemView.text = @"推荐";
      
    [_pageMenuBar setItemViews:@[followsItemView, recommendItemView]];
    [_pageViewController.view addSubview:_pageMenuBar];
    [_pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.centerX.offset(0);
        make.width.offset(160);
        make.height.offset(44);
    }];
    
    [_pageMenuBar scrollToItemAtIndex:1 animated:NO];
}

- (void)_setupGesture {
    _panGesture = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(_handlePan:)];
    _panGesture.delegate = self;
    
    UIScrollView *collectionView = [_pageViewController sj_lookupScrollView];
    [collectionView addGestureRecognizer:_panGesture];
}

#pragma mark - UIGestureRecognizerDelegate

// 是否允许左滑弹出用户个人主页
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( _pageViewController.focusedIndex == 0 )
        return NO;
    
    CGPoint translate = [gestureRecognizer translationInView:gestureRecognizer.view];
    UIScrollView *collectionView = [_pageViewController sj_lookupScrollView];
    return !collectionView.isDragging && !collectionView.isDecelerating && translate.x < 0 && translate.y == 0;
}

#pragma mark - SJDYPlaybackListViewControllerDelegate

- (BOOL)canPerformPlayForListViewController:(SJDYPlaybackListViewController *)vc {
    // 如果 pageViewController 处于拖拽中, 则禁止播放
    switch ( _pageViewController.panGestureRecognizer.state ) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            return NO;
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            return YES;
    }
}

#pragma mark - SJPageMenuBarDelegate, SJPageViewControllerDataSource, SJPageViewControllerDelegate

- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSUInteger)index {
    if ( ![_pageViewController isViewControllerVisibleAtIndex:index] ) {
        if ( _pageViewController.focusedIndex != NSNotFound ) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [(SJDYPlaybackListViewController *)self.pageViewController.focusedViewController playIfNeeded];
            });
        }
        [_pageViewController setViewControllerAtIndex:index];
    }
}

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return _pageMenuBar.numberOfItems;
}

- (__kindof UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    SJDYPlaybackListViewController *vc = SJDYPlaybackListViewController.new;
    vc.delegate = self;
    return vc;
}

- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    [_pageMenuBar scrollInRange:range distanceProgress:progress];
}

- (void)pageViewController:(SJPageViewController *)pageViewController willDisplayViewController:(SJDYPlaybackListViewController *)viewController atIndex:(NSInteger)index {
    for ( SJDYPlaybackListViewController *vc in pageViewController.cachedViewControllers ) {
        [vc pause];
    }
}

- (void)pageViewController:(SJPageViewController *)pageViewController didEndDisplayingViewController:(SJDYPlaybackListViewController *)viewController atIndex:(NSInteger)index {
    [viewController pause];

    SJDYPlaybackListViewController *vc = pageViewController.focusedViewController;
    [vc playIfNeeded];
}
@end
